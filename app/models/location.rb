class Location < ActiveRecord::Base
  belongs_to :zone

  validates :zone, presence: true
  validates :rooms, inclusion: { in: 1..100 }
  validates :max_mds, inclusion: { in: 1..100 }


  DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end
end
