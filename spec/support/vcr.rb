require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock # or :fakeweb
  c.cassette_library_dir = 'spec/cassettes'
  c.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|
  config.before(:each) do |example|
  end

  config.after(:each) do |example|
  end
end
