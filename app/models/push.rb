# Records the activity that occurs as the result of pushing to WIW
class Push < ActiveRecord::Base
  belongs_to :location_plan

  def creates
    theory['creates']
  end

  def updates
    theory['updates']
  end

  def deletes
    theory['deletes']
  end
end
