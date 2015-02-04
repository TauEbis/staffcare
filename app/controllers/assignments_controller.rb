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
          hsh[lp.id] = lp.chosen_grade.shifts.group_by {|s| s.date }
          hsh
        end
      end
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
  end

  # # GET /assignments/new
  # def new
  #   @assignment = Assignment.new
  # end
  #
  # # GET /assignments/1/edit
  # def edit
  # end
  #
  # # POST /assignments
  # # POST /assignments.json
  # def create
  #   @assignment = Assignment.new(assignment_params)
  #
  #   respond_to do |format|
  #     if @assignment.save
  #       format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
  #       format.json { render :show, status: :created, location: @assignment }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @assignment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # PATCH/PUT /assignments/1
  # # PATCH/PUT /assignments/1.json
  # def update
  #   respond_to do |format|
  #     if @assignment.update(assignment_params)
  #       format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @assignment }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @assignment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # DELETE /assignments/1
  # # DELETE /assignments/1.json
  # def destroy
  #   @assignment.destroy
  #   respond_to do |format|
  #     format.html { redirect_to assignments_url, notice: 'Assignment was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

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
