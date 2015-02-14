class GradesController < ApplicationController
  before_action :set_grade, only: [:line_workers, :show, :shifts, :highcharts, :hourly, :update, :destroy]

  def create
    source_grade = policy_scope(Grade).find(params[:grade][:source_grade_id])
    location_plan = source_grade.location_plan
    authorize Grade.new(location_plan: location_plan), :create?  # Fake grade, the real one to be created later
    authorize source_grade, :show?

    @grade = location_plan.copy_grade!(source_grade, current_user)

    Comment.create!(
      user: current_user,
      location_plan: location_plan,
      grade: @grade,
      cause: :copied,
      body: "Copied from #{source_grade.label} to #{@grade.label}",
      metadata: {from: source_grade, to: @grade}
    )

    Rule.copy_template_to_grade(@grade)

    redirect_to rules_grade_path(@grade), notice: 'Physician schedule copied successfully.'
  end

  def line_workers
    gen = LineWorkerShiftGenerator.new(@grade)
    if gen.create!
      redirect_to grade_path(@grade), notice: 'Staffing schedules generated successfully.'
    else
      redirect_to rules_grade_path(@grade), alert: 'Something went wrong. Staffing schedules were not successfully generated.'
    end
  end

  # GET /grades/1
  def show
    respond_to do |format|
      format.html do
        @schedule = @location_plan.schedule
        @zone = @location_plan.location.zone
      end
      format.json do

        data = { grade: {
          id: @grade.id,
          source: @grade.source,
          editable: policy(@grade).update?,
          optimizer: @grade.optimizer?,
          analysis: Analysis.new(@grade).to_knockout
          }
        }

        if @date
          @date_s = @date.to_s

          data[:visits] = @grade.visits[@date_s].map {|count| count.round(2)}

          day = {
            date: @date.to_s,
            formatted_date: I18n.localize(@date, format: :with_dow),
            open_time: @grade.open_times[@date.wday],
            close_time: @grade.close_times[@date.wday],
            analysis: Analysis.new(@grade, @date).to_knockout
          }

          data[:day_info] = day

          all_shifts =  @grade.shifts.includes(:position).for_day(@date).group_by(&:position)
          data[:positions] = all_shifts.map{|pos,shifts| {key: pos.key, name: pos.name, shifts: shifts.map(&:to_knockout)} }
        end

        render json: data
      end
    end
  end

  def shifts
    data = { chosen_grade_id: @grade.id,
             source: @grade.source,
             editable: policy(@grade).update?
    }


    if @date
      data[:shifts] = @grade.shifts.for_day(@date).map(&:to_knockout)
      data[:day_info] = {
        date: @date.to_s,
        formatted_date: I18n.localize(@date, format: :with_dow),
        open_time: @location_plan.open_times[@date.wday],
        close_time: @location_plan.close_times[@date.wday],
      }
    end

    render json: data
  end

  def highcharts
    render json: @grade.for_highcharts(@date)
  end

  def hourly
    render layout: false
  end

  # PATCH /grades/:location_plan_id
  def update
    @grade.update_shift!(@date, params[:shifts])
    @grade.location_plan.dirty!

    Comment.create!(
      user: current_user,
      location_plan: @grade.location_plan,
      grade: @grade,
      cause: :edited,
      body: "Edited #{@grade.label}"
    )

    render text: "OK!"
  end

  def destroy
    @grade.location_plan.dirty!
    @grade.destroy

    Comment.create!(
      user: current_user,
      location_plan: @grade.location_plan,
      grade: @grade,
      cause: :deleted,
      body: "Deleted #{@grade.label}"
    )

    redirect_to @location_plan, notice: 'Coverage plan was successfully destroyed.'
  end

  private

  def set_grade
    if params[:date]
      @date = Date.parse params[:date]
      @date_s = params[:date]
    end

    @grade = policy_scope(Grade).find(params[:id])
    authorize @grade

    @location_plan = @grade.location_plan
  end

end
