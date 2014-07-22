class WiwPusher

  attr_accessor :creates, :deletes, :updates

  def initialize(location_plan)
    @location_plan = location_plan

    build_plan
  end

  # Creates a "plan of action" for how shifts will be synced
  def build_plan
    @creates = []
    @deletes = []
    @updates = []

    local_shifts.each do |shift|
      ws = Wiw::Shift.build_from_shift(shift)

      if shift.wiw_id
        @updates << ws
      else
        @creates << ws
      end
    end

    id_list = Set.new local_shifts.map(&:wiw_id).compact

    remote_shifts.each do |rs|
      if id_list.include? rs.id
        # Do nothing because it'll be updated above
      else
        @deletes << rs
      end
    end
  end

  def local_shifts
    @location_plan.chosen_grade.shifts.all
  end

  def remote_shifts
    Wiw::Shift.find_all_for_location_plan(@location_plan)
  end

  # Synchronizes the shifts in the chosen grade to When I Work
  def push!
    @creates.each do |ws|
      response = ws.create
      ws.source_shift.update_attribute!(:wiw_id, response['shift']['id'])
    end

    @updates.each do |ws|
      ws.update
    end

    @deletes.each do |ws|
      ws.delete
    end
  end
end
