class ZonesController < ApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]

  # GET /zones
  def index
    @zones = policy_scope(Zone).ordered.page params[:page]
  end

  # GET /zones/1
  def show
  end

  # GET /zones/new
  def new
    @zone = Zone.new
    authorize @zone
  end

  # GET /zones/1/edit
  def edit
  end

  # POST /zones
  def create
    @zone = Zone.new(zone_params)
    authorize @zone

    if @zone.save
      redirect_to @zone, notice: 'Zone was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /zones/1
  def update
    if @zone.update(zone_params)
      redirect_to @zone, notice: 'Zone was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /zones/1
  def destroy
    @zone.destroy
    redirect_to zones_url, notice: 'Zone was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = Zone.find(params[:id])
      authorize @zone
    end

    # Only allow a trusted parameter "white list" through.
    def zone_params
      params.require(:zone).permit(:name)
    end
end
