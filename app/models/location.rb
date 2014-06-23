class Location < ActiveRecord::Base
  belongs_to :zone

  validates :zone, presence: true
  validates :rooms, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, numericality: { greater_than: 0, less_than: 100 }

  scope :ordered, -> { order(name: :asc) }

  default_scope -> { order(name: :asc) }


  DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end
end
