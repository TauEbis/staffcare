module Wiw
  class Position
    include HTTParty
    base_uri 'https://api.wheniwork.com/2/positions'
    headers 'W-Token' => Rails.application.secrets.wiw_token, 'Accept' => 'application/json', 'Content-Type' => 'application/json'
    format :json

    def self.find_all_collection
      get('/')['positions'].map{|l| [l['name'], l['id']] }.sort_by{|el| el[0]}
    end
  end
end