require 'ios_device_locator'

module Agents
	class IcloudAgent < Agent

		VALID_ACTION_TYPES = %w[get_location send_message play_sound remote_lock set_device_as_lost remote_wipe]

		description <<-MD
			The iCloud Agent can be scheduled/triggered to interact with your Apple iCloud account (currently only supports Find My iDevice).

			
		MD

		def default_options
			{
				:username => 'Your iCloud username',
				:password => 'Your iCloud password',
				:email_icloud_notifications => true,
				:action => 'send_message',
				:subject => 'Message subject',
				:message => 'Message text',
				:play_sound_with_message => true,
				:phone_number => '555-555-5555',
				:refresh_location => true,
				:device => 1,
				:expected_receive_period_in_days => '1'
			}
		end

		def validate_options
			unless options[:username].present? && options[:password].present? 
				errors.add(:base, 'You must provide your iCloud username and password.')
			end
		end

		default_schedule "every_1d"

		def check
			icloud = IOSDeviceLocator.new(options[:username],options[:password])
			devices = icloud.getDevicesAndLocations
			device = devices[options[:device] - 1]
			case options[:action]
			when 'get_location'

#				create_event :payload => 
			when 'send_message'
			when 'play_sound'
			when 'remote_lock'
				icloud.remoteLock device.id
				payload = {
					'action' => options[:action],
					'device_name' => device.display_name,
					'name' => device.name,
					'message' => 'Remote lock sent.',
					'timestamp' => device.time
					}
				create_event :payload => payload, :lat => device.latitude, :lng => device.longitude
			when 'set_device_as_lost'
			when 'remote_wipe'
			else
			end

			

		end

		def receive(incoming_events)
		end

		def working?
			last_receive_at && last_receive_at > options[:expected_receive_period_in_days].to_i.days.ago
#			event = event_created_within(:expected_receive_period_in_days.days)
		end
	end
end

