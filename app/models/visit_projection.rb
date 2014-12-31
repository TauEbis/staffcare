class VisitProjection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :location

  has_one :grade

  validates :visits, presence: true
  validate :valid_volumes

  def valid_volumes
    unless volumes && !volumes.empty?
      errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
      return
    end
    volumes.each do |k, v|
      unless !v.nil? && v >= 0
        errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
        return
      end
    end
  end

end
