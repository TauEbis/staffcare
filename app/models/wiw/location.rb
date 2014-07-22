module Wiw
  class Location
    base_uri 'https://api.wheniwork.com/2/locations'
    headers 'W-Token' => Rails.application.secrets.wiw_token

    def self.find_all_collection
      all.locations.map{|l| [l['name'], l['id']] }
    end
  end
end
