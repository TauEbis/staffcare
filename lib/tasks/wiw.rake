def auth
  {
    headers: {'W-Token' => Rails.application.secrets.wiw_token},
    format: :json
  }
end

namespace :wiw do
  task :login => :environment do
    r = HTTParty.post 'https://api.wheniwork.com/2/login', body:
                 { username: 'tosbi@imgof.com',
                   password: 'password',
                   key: Rails.application.secrets.wiw_dev_key
                 }.to_json,
                 format: :json
    puts
    puts "TOKEN: "
    puts r['token']
  end

  task :fetch_position_ids => :environment do
    r = HTTParty.get 'https://api.wheniwork.com/2/positions', auth
    require 'pp'
    pp r
  end
end
