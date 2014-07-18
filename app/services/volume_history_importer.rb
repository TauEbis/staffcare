
class VolumeHistoryImporter
  include HTTParty
  attr_reader :start_date, :end_date, :location, :session_id
  base_uri 'https://api.citymd.com/rio'

  USER_ENV_KEY = "CITYMD_API_REPORTS_USER"
  PASS_ENV_KEY = "CITYMD_API_REPORTS_PASSWORD"

  # Create a new object to wrap a connection to the server
  # start_date - Beginning of date range to request data
  # end_date - End of " " " " "
  # locations - An array of location GUIDs or nil for all.
  def initialize(start_date, end_date, location = nil)
    @location ||= 'ALL'
    # FIXME: These values should be 1) changed and 2) Not hard coded.
    @username = ENV[USER_ENV_KEY]||'Rio'
    @password = ENV[PASS_ENV_KEY]||'CitymdRio'

    if @username and @password
      @options = { query: { startdate: start_date, enddate: end_date,
                            servicesiteuid: @location } }
      @session_id = nil
    else
      raise "No API password found in the environment! Set #{USER_ENV_KEY} and #{PASS_ENV_KEY} to correct this error."
    end
  end

  def self.valid_guid?(guid)
    return /\h\h\h\h\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\h\h\h\h\h\h\h\h/.match(guid)
  end

  def authenticated?
    if @session_id
      return true
    else
      return false
    end
  end

  def authenticate
    response = self.class.get('/authenticate', { query: { username: @username, password: @password } })
    if response.code == 200
      if self.class.valid_guid?(response.body)
        @sessiond_id = response.body
        @options['sessionID'] = @session_id
      else
        raise "Authentication error- Failed to receive a valid session key from the server: #{response.body}"
      end
    else
      puts response.code, response.message, response.headers.inspect
      raise "Authentication error- Unable to authenticate to the remote server."
    end
  end

  def fetch_data
    response = self.class.get('/patientload', @options)
    # TODO: Check for problems
    # TODO: Throw if anything goes wrong
    return response.body
  end

end


