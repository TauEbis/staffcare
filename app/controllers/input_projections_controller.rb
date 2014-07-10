class InputProjectionsController < ApplicationController

  before_action :set_input_projection, only: [:new, :edit, :update, :destroy]
  before_action :set_locations, only: [:index, :new, :edit, :create, :update ]
  skip_after_filter :verify_authorized, only: [:import]

  # GET /input_projections
  def index
    @projections = policy_scope(InputProjection).ordered
    authorize @projections
    respond_to do |format|
      format.html
      format.csv { send_data @projections.to_csv }
      format.xls # { send_data @projections.to_csv(col_sep: "\t") } # this seems like it might be suffficient
    end
  end

  # GET /input_projections/new
  def new
  end

  # POST /input_projections
  def create
    @input_projection = InputProjection.new(input_projection_params)
    authorize @input_projection
    if @input_projection.save
      redirect_to input_projections_url, notice: 'Input Projection was successfully created.'
    else
      render :new
    end
  end

  # GET /input_projections/1/edit
  def edit
  end

# PATCH/PUT /input_projections/1
  def update
    if @input_projection.update(input_projection_params)
      redirect_to input_projections_url, notice: 'Input Projection was successfully updated.'
    else
      render 'edit'
    end
  end

 # DELETE /input_projections/1
  def destroy
    @input_projection.destroy
    redirect_to input_projections_url, notice: 'Input Projection was successfully destroyed.'
  end

  # POST
  def import
    InputProjection.import(params[:file])
    redirect_to input_projections_url, notice: 'Input Projections successfully imported.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_input_projection
      @input_projection =  params[:id] ? InputProjection.find(params[:id]) : InputProjection.new
      authorize @input_projection
      @locations = Location.ordered.all
    end

    def set_locations
      @locations = Location.ordered.all
    end

    # Strong params -- only allow a trusted parameter "white list" through.
    def input_projection_params
      volume_by_location_to_i
      params.require(:input_projection).permit(:start_date, :end_date, :volume_by_location => Location.pluck(:id).map(&:to_s))
    end

    def volume_by_location_to_i
      params[:input_projection][:volume_by_location].each do |k, v|
        params[:input_projection][:volume_by_location][k] = v.to_i
      end
    end

end