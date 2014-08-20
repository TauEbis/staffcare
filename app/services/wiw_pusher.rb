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
    @remote_updates = {}
    @no_changes = []

    local_shifts.each do |shift|
      ws = Wiw::Shift.build_from_shift(shift)

      if shift.wiw_id
        id = shift.wiw_id
        rs = remote_shifts[id]

        if rs && !rs.should_update?(shift)
          @no_changes << ws
        else
          @updates << ws
          @remote_updates[id] = rs
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

    @push.theory = {'creates' => @creates, 'updates' => @updates, 'remote_updates' => @remote_updates, 'deletes' => @deletes, 'no_changes' => @no_changes}
  end

  def local_shifts
    @_local_shifts ||= @location_plan.chosen_grade.shifts.includes(:grade).all
  end

  def remote_shifts
    @_remote_shifts ||= Wiw::Shift.find_all_for_location_plan(@location_plan).index_by(&:id)
  end

  # Synchronizes the shifts in the chosen grade to When I Work
  def push!
    # Initial save saves the theory state just prior to the run
    @push.save!
    log = {}

    @updates.each do |ws|
      response = ws.update

      # Create if the update failed
      unless response.success?
        @creates << ws
      end

      log[ws.id] = {action: 'update', shift: ws, response: response}
      yield if block_given?
    end

    @creates.each do |ws|
      response = ws.create
      log[ws.id] = {action: 'create', shift: ws, response: response}
      new_id = response['shift'] || {}
      new_id = new_id['id']
      ws.source_shift.update_attribute(:wiw_id, new_id)
      yield if block_given?
    end

    @deletes.each do |ws|
      response = ws.delete
      log[ws.id] = {action: 'delete', shift: ws, response: response}
      yield if block_given?
    end

    @push.update_attribute(:log, log)
    @push.location_plan.update_attribute(:wiw_sync, :synced)
  end
end
