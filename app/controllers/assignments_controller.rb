class AssignmentsController < ApplicationController
  #before_action :set_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_schedule
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  # GET /assignments
  # GET /assignments.json
  def index
    @wide_container = true # Control the body wrapper css class for the giant grid

    @location_plans = @schedule.location_plans

    respond_to do |format|
      format.html
      format.json do
        @shifts = @schedule.location_plans.inject({}) do |hsh, lp|
          hsh[lp.id] = lp.chosen_grade.shifts.md.group_by {|s| s.date }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
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
