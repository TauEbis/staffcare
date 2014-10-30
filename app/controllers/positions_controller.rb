class PositionsController < ApplicationController

 before_action :set_position, only: [:edit, :update]

  # GET /positions
  def index
    @positions = policy_scope(Position).ordered
    authorize @positions
  end

  # GET /positions/1
  def edit
  end

  # Patch /positions/1
  def update
    if @position.update(position_params)
      redirect_to positions_path, notice: 'Position was successfully updated.'
    else
      render :edit
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_position
      @position = Position.find(params[:id])
      authorize @position
    end

    # Only allow a trusted parameter "white list" through.
    def position_params
      params.require(:position).permit(:name, :hourly_rate, :wiw_id)
    end
end