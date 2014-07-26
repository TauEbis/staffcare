class Heatmap < ActiveRecord::Base
  validates :days, presence:true

  belongs_to :location
  has_one :report_server_ingest

  after_initialize :init

  def init
    @days = {}
    Date::DAYNAMES.each do |day|
      @days[day] = {}
    end
  end

  def set(day, hour, percentage)
    @days[day][hour] = percentage
  end

end

