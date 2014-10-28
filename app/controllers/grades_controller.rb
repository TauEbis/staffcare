class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :shifts, :highcharts, :hourly, :update, :destroy]

  def create
    source_grade = policy_scope(Grade).find(params[:grade][:source_grade_id])
    location_plan = source_grade.location_plan
    authorize Grade.new(location_plan: location_plan), :create?  # Fake grade, the real one to be created later
    authorize source_grade, :show?

    @grade = location_plan.copy_grade!(source_grade, current_user)
    redirect_to location_plan, notice: 'Copied successfully.  You may now edit the coverage.'
  end

  # GET /grades/1
  def show
    pts     = Grade.unoptimized_sum(@grade)

    data = { chosen_grade_id: @grade.id,
             source: @grade.source,
             editable: policy(@grade).update?,
             grade_points: pts,
             grade_hours:  pts['hours'],
             grade_letters: @grade.month_letters,
             grade_opt_diff: @grade.month_opt_diff,
             month_stats: @grade.month_stats
            }

    if @date
      data[:day_info] = {
        date: @date.to_s,
        formatted_date: I18n.localize(@date, format: :with_dow),
        open_time: @location_plan.open_times[@date.wday],
        close_time: @location_plan.close_times[@date.wday],
      }
      data[:day_points] = @grade.points[@date_s]
      data[:shifts]     = @grade.shifts.for_day(@date).map(&:to_knockout)
      data[:wages] = @grade.wages(@date)
      data[:total_wait] = @grade.total_wait_time(@date)
      data[:work_rate] = @grade.average_work_rate(@date)
      data[:time_wasted] = @grade.time_wasted(@date)
      data[:day_letters] = @grade.day_letters[@date_s]
      data[:visits] = @grade.totals(@date)[:visits]
      data[:opt_diff] = @grade.day_opt_diff[@date_s]
    end

    render json: data
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
    render text: "OK!"
  end

  def destroy
    @grade.location_plan.dirty!
    @grade.destroy
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
