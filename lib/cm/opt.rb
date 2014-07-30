require 'optparse'
require 'ostruct'
require 'pp'

module CM

  # Option parse utility
  class Opt

    def self.parse(args)
      opt = OpenStruct.new

      opt.profile = 'proxy'
      opt.price = '0.05' # default price in dollar
      opt.instance_type = 'm3.large'
      opt.image_id = 'ami-a1124fa0' # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type - ami-a1124fa0

      opt.tag_name = 'evans-proxy'

      #opt.zones = %w{ap-northeast-1a ap-northeast-1b ap-northeast-1c}

      opt.instance_count = 1

      parser = OptionParser.new do |op|
        op.banner = 'Usage: cm_aws [options]'

        op.separator ''
        op.separator 'Specific options:'

        # Mandatory arguments.
        op.on('-p', '--price PRICE', String, 'Specify the max spot price') do |p|
          opt.price = p
        end

        op.on('-t', '--instance-type INSTANCE_TYPE', String, 'AWS EC2 instance type.') do |p|
          opt.instance_type = p
        end

        op.on('--image-id IMAGE_ID', String, 'AWS EC2 image identifier') do |p|
          opt.image_id = p
        end

        op.on('-f', '--profile PROFILE', String, 'Select profile') do |p|
          opt.profile = p
        end

        op.on('--tag-name TAG_NAME', String, 'EC2 instance tag name (user data)') do |p|
          opt.tag_name = p
        end

        op.separator ''
        op.separator 'Common options:'

        op.on_tail('-h', '--help', 'Show this message') do
          puts op
          exit
        end

        op.on_tail('-v', '--version', 'Show version') do
          puts '0.0.1'
          exit
        end
      end

      # do parse!
      parser.parse!(args)
      opt
    end

  end

end
