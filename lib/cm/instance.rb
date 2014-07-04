require 'aws'

module CM

	# Instance manager, a wrap for AWS EC2
	class Instance
		def initialize(opt)
			@opt = opt

			@ec2 = AWS.ec2
			@conn = @ec2.client
		end	

    def spot_request_spec{
        spot_price: "0.15",
        instance_count: 20,
        launch_specification: {
            image_id: 'ami-9999999d',
            key_name: 'us-keypair2',
            instance_type: 'm1.large',
            security_groups: ['default'],
            user_data: Base64.encode64(opt.tag_name),
            placement: {
                availability_zone: opt.zone
            }
        }
       }
    end
	end

end
