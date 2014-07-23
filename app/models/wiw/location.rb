module Wiw
  class Location
    include HTTParty
    base_uri 'https://api.wheniwork.com/2/shifts'
    headers 'W-Token' => Rails.application.secrets.wiw_token, 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    def self.find_all_collection
      all.locations.map{|l| [l['name'], l['id']] }
    end
  end
end
