# Records the activity that occurs as the result of pushing to WIW
class Push < ActiveRecord::Base
  belongs_to :location_plan

  enum state: [ :not_run, :running, :complete, :error ]

  scope :ordered, -> { order(id: :desc) }

  def creates
    theory['creates'] || []
  end

  def updates
    theory['updates'] || []
  end

  def deletes
    theory['deletes'] || []
  end

  def no_changes
    theory['no_changes'] || []
  end

  def remote_updates
    theory['remote_updates'] || {}
  end

  def total_length
    # Don't include no_changes
    creates.length + updates.length + deletes.length
  end
end
