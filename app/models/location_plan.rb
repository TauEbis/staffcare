# Records location configuration at time a schedule is generated
# Corresponds to a per-location schedule in the UI
class LocationPlan < ActiveRecord::Base

  has_many :pushes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :grades, dependent: :destroy
  # grades records the grading/score for the schedule for the given scheduling options-

  belongs_to :chosen_grade, class_name: 'Grade'
  belongs_to :location
  belongs_to :schedule

  delegate :name, to: :location


  enum approval_state: [:pending, :manager_approved, :rm_approved]
  enum wiw_sync: [:unsynced, :dirty, :synced]

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }
  scope :for_location, -> (location) { where(location_id: location.id).first }
  scope :for_user, -> (user) { where(location_id: user.relevant_locations.pluck(:id)) }
  scope :assigned, -> { where(location_id: Location.assigned.pluck(:id)) }
  scope :ordered, -> { joins(:location).order('locations.name ASC')}

  # For a given collection of location_plans, return their 'base' state
  # If any are pending, then the whole collective state is pending
  def self.collective_state(location_plans)
    int_states = location_plans.map{|lp| lp[:approval_state]}
    LocationPlan.approval_states.key(int_states.min || 0)
  end

  def dirty!
    update_attribute(:wiw_sync, :dirty) if synced?
  end

  def complete?
    chosen_grade.complete?
  end

  # Copies the chosen grade to a new grade
  def copy_grade!(grade, user)
    LocationPlan.transaction do
      g = self.grades.create!(grade.attributes.merge(id: nil, created_at: nil, source: 'manual', user: user))
      g.clone_shifts_from!(grade)
      self.update_attribute(:chosen_grade_id, g.id)
      dirty!

      g
    end
  end
end
