class AssignmentsController < ApplicationController
  #before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_schedule
  before_action :set_zones, only: [:index]
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  # GET /assignments
  # GET /assignments.json
  def index
    @wide_container = true # Control the body wrapper css class for the giant grid

    @start_date = params[:start_date] ? Date.parse(params[:start_date].to_s) : @schedule.starts_on
    @end_date = params[:end_date] ? Date.parse(params[:end_date].to_s) : @schedule.ends_on

    respond_to do |format|
      format.html
      format.json do
        @shifts = @location_plans.inject({}) do |hsh, lp|
          hsh[lp.id] = lp.chosen_grade.shifts.for_date_range(@start_date..(@end_date+1)).md.group_by {|s| s.date } # Plus one here because arel range doesn't understand how to include the end date
          hsh
        end
      end
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  private
    def set_zones
      @zone = if params[:zone_id]
                user_zones.find(params[:zone_id].to_i)
              else
                user_zones.ordered.first
              end

      @zones = user_zones.assigned.ordered

      @location_plans = @schedule.location_plans.for_user(current_user).where(location_id: @zone.location_ids)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params[:assignment]
    end

    def set_schedule
      @schedule = Schedule.includes(location_plans: {location: [:zone], chosen_grade: [:shifts]}).find(params[:schedule_id])
      authorize @schedule
    end
end
