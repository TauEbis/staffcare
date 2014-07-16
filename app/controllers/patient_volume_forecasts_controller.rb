class PatientVolumeForecastsController < ApplicationController

  before_action :set_patient_volume_forecast, only: [:new, :edit, :update, :destroy]
  before_action :set_locations, only: [:index, :new, :edit, :create, :update ]

  # GET /patient_volume_forecasts
  def index
    @patient_volume_forecasts = policy_scope(PatientVolumeForecast).ordered
    authorize @patient_volume_forecasts
    respond_to do |format|
      format.html
      format.csv { send_data @patient_volume_forecasts.to_csv }
      format.xls
      # { send_data @patient_volume_forecasts.to_csv(col_sep: "\t") }
    end
  end

  # GET /patient_volume_forecasts/new
  def new
  end

  # POST /patient_volume_forecasts
  def create
    @patient_volume_forecast = PatientVolumeForecast.new(patient_volume_forecast_params)
    authorize @patient_volume_forecast
    if @patient_volume_forecast.save
      redirect_to patient_volume_forecasts_url, notice: 'Patient volume forecast was successfully created.'
    else
      render :new
    end
  end

  # GET /patient_volume_forecasts/1/edit
  def edit
  end

# PATCH/PUT /patient_volume_forecasts/1
  def update
    if @patient_volume_forecast.update(patient_volume_forecast_params)
      redirect_to patient_volume_forecasts_url, notice: 'Patient Volume Forecast was successfully updated.'
    else
      render 'edit'
    end
  end

 # DELETE /patient_volume_forecasts/1
  def destroy
    @patient_volume_forecast.destroy
    redirect_to patient_volume_forecasts_url, notice: 'Patient Volume Forecast was successfully destroyed.'
  end

  # POST
  def import
    authorize current_user, :create?
    unless (params[:file])
         redirect_to patient_volume_forecasts_url, notice: 'Please select a file to import.'
    else
         PatientVolumeForecast.import(params[:file])
         ActiveRecord::Base.connection.reset_pk_sequence!('patient_volume_forecasts')
         redirect_to patient_volume_forecasts_url, notice: 'Patient Volume Forecasts successfully imported.'
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_patient_volume_forecast
      @patient_volume_forecast =  params[:id] ? PatientVolumeForecast.find(params[:id]) : PatientVolumeForecast.new
      authorize @patient_volume_forecast
      @locations = Location.ordered.all
    end

    def set_locations
      @locations = Location.ordered.all
    end

    # Strong params -- only allow a trusted parameter "white list" through.
    def patient_volume_forecast_params
      volume_by_location_to_f
      params.require(:patient_volume_forecast).permit(:start_date, :end_date, :volume_by_location => Location.pluck(:report_server_id))
    end

    def volume_by_location_to_f
      params[:patient_volume_forecast][:volume_by_location].each do |k, v|
        params[:patient_volume_forecast][:volume_by_location][k] = v.to_f
      end
    end

end
