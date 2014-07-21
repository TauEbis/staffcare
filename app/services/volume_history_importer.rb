require 'json'

class VolumeHistoryImporter
  include HTTParty
  attr_reader :start_date, :end_date, :session_id
  attr_accessor :username, :password
  base_uri 'https://api.citymd.com/rio'

  USER_ENV_KEY = "CITYMD_API_REPORTS_USER"
  PASS_ENV_KEY = "CITYMD_API_REPORTS_PASSWORD"

  BAD_IP_MESSAGE = "is not an authorized IP Address."
  BAD_USERNAME_MESSAGE = "Invalid Login"
  BAD_PASSWORD_MESSAGE = "Invalid login"

  #debug_output $stderr
  # Create a new object to wrap a connection to the server
  # start_date - Beginning of date range to request data
  # end_date - End of " " " " "
  # locations - An array of location GUIDs or nil for all.
  def initialize(start_date, end_date, location)
    location ||= 'ALL'
    # FIXME: These values should be 1) changed and 2) Not hard coded.
    @username = ENV[USER_ENV_KEY]||'Rio'
    @password = ENV[PASS_ENV_KEY]||'CitymdRio'

    if @username and @password
      @options = { query: { startdate: start_date.to_s, enddate: end_date.to_s,
                            servicesiteuid: location } }
      @session_id = nil
    else
      raise "No API password found in the environment! Set #{USER_ENV_KEY} and #{PASS_ENV_KEY} to correct this error."
    end
  end

  def self.valid_guid?(guid)
    if /^\h\h\h\h\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\h\h\h\h\h\h\h\h$/.match(guid) != nil
      return true
    else
      return false
    end
  end

  def authenticated?
    if @session_id != nil
      return true
    else
      return false
    end
  end

  def authenticate!
    response = self.class.get('/authenticate', { query: { username: @username, password: @password } })
    if response.code == 200
      if self.class.valid_guid?(response.body)
        @session_id = response.body.chomp
        @options[:query][:sessionID] = @session_id
        @options[:headers] = { 'Cookie' => response.headers['Set-Cookie'] }
      else
        handle_auth_error(response.body)
      end
    else
      raise IOError, "Connection error- got #{response.message} (#{response.code}) from server."
    end
  end

  def fetch_data!
    if self.session_id == nil
      self.authenticate!()
    end
    response = self.class.get('/patientload', @options)
    if response.code == 200
      return JSON.parse(response.body)
    else
      raise IOError, "Error retrieving data- got #{response.message} (#{response.code}) from server."
    end
  end

  private

  def handle_auth_error(msg)
    if msg.match(BAD_USERNAME_MESSAGE)
      raise SecurityError, "Authentication error- Bad username."
    elsif msg.match(BAD_PASSWORD_MESSAGE)
      raise SecurityError, "Authentication error- Bad password."
    elsif msg.match(BAD_IP_MESSAGE)
      raise SecurityError, "Authentication error- IP is blocked."
    else
      raise SecurityError, "Authentication error- received #{msg} from server."
    end
  end

end


