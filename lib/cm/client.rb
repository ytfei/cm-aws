require 'aws'
require 'cm/util'
require 'base64'

module CM

  # Instance manager, a wrap for AWS EC2
  class Client
    include CM::Util

    def initialize(opt)
      @opt = opt

      @ec2 = AWS::EC2.new(:ec2_endpoint => 'ec2.ap-northeast-1.amazonaws.com') # connect to Asia Pacific Tokyo
      @conn = @ec2.client

      @log = new_logger
    end

    def start
      unless start_proxy
        spot_and_wait
      end

      start_proxy
    end

    # terminate the exist servers
    def stop
      @ec2.instances.each do |inst|
        if inst.api_termination_disabled?
          @log.warn "#{inst.id} cannot be terminated with ruby api !!!"
        else
          @log.info "terminating #{inst.id}"
          inst.terminate
          @log.info "done!"
        end
      end
    end

    private

    def start_proxy
      instances = @ec2.instances.inject({}) { |r, inst| r[inst.id] = inst.ip_address; r }

      if instances.count > 0
        ip = instances.first[1]
        cmd = "ssh -o StrictHostKeyChecking=no -i /home/evans/.ssh/evans-proxy.pem -D 1080 ubuntu@#{ip}"

        @log.info "Execute the following command for ssh dynamic forward: \n #{cmd}"

        exec cmd
        # no need to return
      end

      false
    end

    def spot_and_wait(timeout = 0)
      resp = @conn.request_spot_instances(spot_request_spec)

      req_ids = resp[:spot_instance_request_set].map { |r| r[:spot_instance_request_id] }

      wait_for_spot(req_ids, timeout)
    end

    def wait_for_spot(request_ids, timeout)
      @log.info('Waiting for spot request instances')

      start_at = Time.now
      loop do
        response = @conn.describe_spot_instance_requests(:spot_instance_request_ids => request_ids)
        statuses = response[:spot_instance_request_set].map { |rr| rr[:state] }

        if statuses.all? { |s| s == 'active' }
          @log.info('Spot request instances fulfilled')
          return response[:spot_instance_request_set].map { |rr| rr[:instance_id] }
        end

        if statuses.all? { |s| s == 'cancelled' }
          @log.info('Spot request instances cancelled')
          return []
        end

        result = statuses.uniq.inject({}) { |r, status| r[status] = statuses.count(status); r }
        @log.info("Spot instances in states: #{result}")

        if timeout > 0 and Time.now - start_at > timeout
          # cancel the spot request.
          @log.error 'we should cancel the spot request'
        end

        @log.info 'Wait 8 seconds for next round of checking.'
        sleep(8)
      end

    end

    # default spot specification
    def spot_request_spec(spec = {})
      spec = {
          spot_price: @opt.price,
          instance_count: @opt.instance_count,
          launch_group: 'proxy',
          launch_specification: {
              image_id: @opt.image_id,
              key_name: 'evans-proxy', # create a key pair for proxy usage
              instance_type: @opt.instance_type,
              security_groups: ['evans-proxy'],
              user_data: Base64.encode64(@opt.tag_name),
          }
      }.update(spec)

      @log.debug spec

      return spec
    end

    # does this necessary?
    def default_request_spec

    end

  end

end
