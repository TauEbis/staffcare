class ReportServerFetcher
  include HTTParty
  base_uri 'https://api.citymd.com/rio'

  BAD_IP_MESSAGE = "is not an authorized IP Address."
  BAD_USERNAME_MESSAGE = "Invalid Login"
  BAD_PASSWORD_MESSAGE = "Invalid login"

  #debug_output $stderr

  # Create a new object to wrap a connection to the server
  def initialize
    @options = {}
    @options[:query] = {}
    @session_id = nil

    @username = Rails.application.secrets.rs_username
    @password = Rails.application.secrets.rs_password

    if @username and @password
    else
      raise "No CityMD API username/password found in the environment!"
    end
  end

  # NOTE: JSON data records are structured: [{"Name"=>"PC Bellmore", "ServiceSiteUid"=>"28a537db-55f0-434d-9b90-e1245b6a46bd", "VisitDay"=>4, "VisitHour"=>"20:30:00", "VisitCount"=>1.928571}]
  # NOTE: VisitDay is 1-7 with Sunday = 1
  # NOTE: VisitCount is an average over the querry date range (start_date to end_date)
  # start_date - Beginning of date range to request data
  # end_date - End of " " " " "
  # locations - An array of location GUIDs or nil for all.
  def fetch_data!(start_date, end_date, locations = 'ALL')
    @options[:query] = { startdate: start_date.to_s, enddate: end_date.to_s, servicesiteuid: locations }

    authenticate! if !authenticated?
    response = self.class.get('/patientload', @options)
    if response.code == 200
      return JSON.parse(response.body)
    else
      raise IOError, "Error retrieving data- got #{response.message} (#{response.code}) from server."
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
        self.class.handle_auth_error(response.body)
      end
    else
      raise IOError, "Connection error- got #{response.message} (#{response.code}) from server."
    end
  end

  def self.valid_guid?(body)
    /^\h\h\h\h\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\-\h\h\h\h\h\h\h\h\h\h\h\h$/.match(body) != nil
  end

  def self.handle_auth_error(msg)
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

  private

    def authenticated?
      @session_id != nil
    end
end


