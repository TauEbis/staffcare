# This service combines together the LocationPlan (and it's Chosen Grade) and the data coming out
# of WhenIWork to decide what should or should not be created
#
# It's by-product is a Push record recording what it thought was the best course of action
# and the results of the push
class WiwPusher

  attr_accessor :creates, :deletes, :updates, :location_plan, :push

  def initialize(location_plan_or_push)
    case location_plan_or_push
      when LocationPlan
        @location_plan = location_plan_or_push
        @push = location_plan.pushes.build
        build_theory
      when
        @push = location_plan_or_push
        @location_plan = @push.location_plan
        # We rebuild the theory here because the objects inside the push are now Hashes
        # And we want them to be Wiw::Shifts instead
        build_theory
      else
        raise "You must provide a LocationPlan or a Push"
    end
  end

  # Creates a theoretical "plan of action" for how shifts will be synced
  def build_theory
    @creates = []
    @deletes = []
    @updates = []
    @no_changes = []

    local_shifts.each do |shift|
      ws = Wiw::Shift.build_from_shift(shift)

      if shift.wiw_id
        rs = remote_shifts[shift.wiw_id.to_i]

        if rs && !rs.should_update?(shift)
          @no_changes << ws
        else
          @updates << ws
        end
      else
        @creates << ws
      end
    end

    id_list = Set.new local_shifts.map(&:wiw_id).compact

    remote_shifts.each do |id, rs|
      if id_list.include? rs.id
        # Do nothing because it'll be updated above
      else
        @deletes << rs
      end
    end

    @push.theory = {'creates' => @creates, 'updates' => @updates, 'deletes' => @deletes, 'no_changes' => @no_changes}
  end

  def local_shifts
    @_local_shifts ||= @location_plan.chosen_grade.shifts.includes(:grade).all
  end

  def remote_shifts
    @_remote_shifts ||= Wiw::Shift.find_all_for_location_plan(@location_plan).index_by(&:id)
  end

  # Synchronizes the shifts in the chosen grade to When I Work
  def push!
    @creates.each do |ws|
      response = ws.create
      ws.source_shift.update_attribute(:wiw_id, response['shift']['id'])
      yield if block_given?
    end

    @updates.each do |ws|
      ws.update
      yield if block_given?
    end

    @deletes.each do |ws|
      ws.delete
      yield if block_given?
    end

    @push.save!
  end
end
