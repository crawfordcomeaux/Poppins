require 'base64'
require 'json'
require 'net/http'
require 'net/https'
require 'ostruct'
require 'typhoeus'
require 'uri'

class IOSDeviceLocator

  INIT_CLIENT         = 'initClient'
  REFRESH_CLIENT      = 'refreshClient'
  SEND_MESSAGE        = 'sendMessage'
  REMOTE_LOCK         = 'remoteLock'
  REMOTE_WIPE         = 'remoteWipe'
  REMOVE_DEVICE       = 'removeDevice'
  SAVE_LOC_FOUND_PREF = 'saveLocFoundPref'
  PLAY_SOUND          = 'playSound'
  SET_DEVICE_AS_LOST  = 'lostDevice'


  def initialize username, password
    @username = username
    @password = password
    @partition = nil

    # Except for the initClient method, the format for Find My iPhone (FMI) API endpoints is:
    #   https://<partition>/<baseURI>/<username>/<method>
    #
    # The Find My iPhone app & webapp both use the prsId in place of @username.
    # Should @username get deprecated in favor of prsId, it can be retrieved like so:
    #   response = post(@initClient)
    #   prsId = JSON.parse(response.body)['serverContext']['prsId']

    @baseURI = "/fmipservice/device/#{@username}/"

    # API endpoint methods


    # Initial connection to API is with an endpoint that returns a 'partition'
    # that identifies the URL to use for further API calls, so let's grab it.

    getPartition

  end

  def getDevicesAndLocations
    response = post(INIT_CLIENT)
    devices_json = JSON.parse(response.body)['content']
    devices_json.collect { |device| hash_to_device(device) }
  end

  # Unsure what the difference between initClient & refreshClient is (besides the endpoint),
  # but there's probably a good reason the official app uses refreshClient to update device info.

  def updateDevicesAndLocations
    response = post(REFRESH_CLIENT)
    devices_json = JSON.parse(response.body)['content']
    devices_json.collect { |device| hash_to_device(device) }
  end

  # removeDevice only works if the device being removed is offline.

  def removeDevice deviceId
    options = { 'device' => deviceId }
    post REMOVE_DEVICE, options
  end

  # Play a sound while displaying an alert with an optional custom title

  def playSound deviceId, subject
    options = {
      'device'  => deviceId,
      'subject' => subject
    }
    post PLAY_SOUND, options
  end

  # If a device goes offline and locFoundEnabled is set to true, then a notification
  # email will be sent to the account owner.

  def saveLocFoundPref deviceId, locFoundEnabled = true
    options = {
      'device' => deviceId,
      'locFoundEnabled' => locFoundEnabled
    }
    post SAVE_LOC_FOUND_PREF, options
  end

  # sendMessage....sends a message (with the option to play a sound)

  def sendMessage deviceId, subject = '', text = '', sound = false
    options = {
      'device'   => deviceId,
      'sound'    => sound,
      'subject'  => subject,
      'text'     => text,
      'userText' => true
    }
    post SEND_MESSAGE, options
  end

  # remoteLock merely sends the phone to the lock screen.
  # Changing the passcode no longer works & may have been deprecated in the official API.
  # If no passcode is set on the device, it can be still set it this way.

  def remoteLock deviceId, oldPasscode = '', passcode = ''
    options = {
      'device'      => deviceId,
      'oldPasscode' => oldPasscode,
      'passcode'    => passcode
    }
    post REMOTE_LOCK, options
  end

  # Tested and working. If you want to try it on your own device, just know that it took a
  # 16GB iPhone 5 running ios 6.1.4 with 2.5GB free:
  #   15 mins to become usable (default apps and a few random others installed)
  #   1.25 hours to be fully restored (includes prev. noted 15 mins)
  #   Several weeks before all configs were returned to normal (mostly due to laziness on my behalf)
  #
  # - Crawford

  def remoteWipe devicedid
    options = { 'device' => deviceId }
    post REMOTE_WIPE, deviceId
  end

  # Sets the phone as 'lost', equivalent to sending remoteLock & sendMessage, with the exception of
  # displaying a phone number & a "Call" button in the message.

  def setDeviceAsLost deviceId, text = '', sound = false, trackingEnabled = true, ownerNbr = '', emailUpdates = true, lostModeEnabled = true
    options = {
      'device'          => deviceId,
      'text'            => text,
      'sound'           => sound,
      'trackingEnabled' => trackingEnabled,
      'ownerNbr'        => ownerNbr,
      'emailUpdates'    => emailUpdates,
      'lostModeEnabled' => lostModeEnabled,
      'userText'        => text.empty? ? false : true
    }
    post SET_DEVICE_AS_LOST, options
  end


  private

  def getPartition
    response = post(@initClient)
    @partition = response.headers['X-Apple-MMe-Host']
  end

  def post_headers
    {
      # Replaced Authorization header with userpwd in the Typhoeus::Request at end of method
      # because it's a more standard approach, but preserved it here for reference.
      #   'Authorization' => "Basic #{Base64.encode64("#{@username}:#{@password}").chomp!}",
      'Content-Type'          => 'application/json; charset=utf-8',
      'X-Apple-Find-Api-Ver'  => '2.0',
      'X-Apple-Authscheme'    => 'UserIdGuest',
      'X-Apple-Realm-Support' => '1.0',
      'User-Agent'            => 'Find iPhone/1.4 MeKit (iPad: iPhone OS/4.2.1)',
      'X-Client-Name'         => 'iPad',
      'X-Client-UUID'         => '0cf3dc501ff812adb0b202baed4f37274b210853',
      'Accept-Language'       => 'en-us',
      'Connection'            => 'keep-alive'
    }
  end

  def post url, options = nil
    uri = @partition ? "https://#{@partition}#{@baseURI}#{url}" : "https://fmipmobile.icloud.com#{@baseURI}#{url}"

    unless options.nil?
      clientContext = {
        'clientContext' => {
          'appName'      => 'FindMyiPhone',
          'appVersion'   => '2.0.2',
          'shouldLocate' => false
        }
      }
      body = JSON.generate(clientContext.merge(options))

      Typhoeus::Request.post(uri, userpwd: "#{@username}:#{@password}", headers: post_headers, followlocation: true, verbose: true, maxredirs: 10, body: body)
    else
      Typhoeus::Request.post(uri, userpwd: "#{@username}:#{@password}", headers: post_headers, followlocation: true, verbose: true, maxredirs: 10)
    end
  end

  def hash_to_device(hsh)
    device = OpenStruct.new
    device.id = hsh['id']
    device.name = hsh['name']
    device.class = hsh['deviceClass']
    device.display_name = hsh['deviceDisplayName']
    device.model = hsh['deviceModel']

    if (location = hsh['location'])
      device.latitude = location['latitude']
      device.longitude = location['longitude']
      device.time = location['timeStamp']
    end

    device
  end

end

# USAGE: $ ./ruby ios_device_locator username password
if __FILE__ == $0
  r = IOSDeviceLocator.new(ARGV[0], ARGV[1])
  devices = r.getDevicesAndLocations
  devices.each { |d| puts "#{d.name} - (#{d.latitude}, #{d.longitude})" }
end
