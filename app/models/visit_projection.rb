# A record of the visit projection used by the optimizer to generate a schedule and the data used to create the projection
class VisitProjection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :location

  has_many :grades

  validates :visits, presence: true
  validate :valid_volumes

  enum volume_source: [:patient_volume_forecasts, :volume_forecaster]

  def valid_volumes
    if patient_volume_forecasts?
      unless volumes && !volumes.empty?
        errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
        return
      end
      volumes.each do |k, v|
        unless !v.nil? && v >= 0 ||
          errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
          return
        end
      end

    elsif volume_forecaster?
      unless volumes && !volumes.empty?
        errors.add(:base, "The forecaster could not generate valid forecasts for this schedule.")
        return
      end
      volumes.each do |day_key, volume_chunk_array|
        volume_chunk_array.each do |v|
          unless !v.nil? && v >= 0 ||
            errors.add(:base, "The forecaster could not generate valid forecasts for this schedule.")
            return
          end
        end
      end
    end

  end

end
