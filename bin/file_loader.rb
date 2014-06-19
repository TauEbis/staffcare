Dir['./app/models/shifty/*.rb'].each { |file| require file }
Dir['./app/services/shifty/*.rb'].each { |file| require file }