class Location < ActiveRecord::Base
  belongs_to :zone

  validates :zone, presence: true

  DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
end
