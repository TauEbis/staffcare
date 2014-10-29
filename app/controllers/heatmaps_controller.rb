class HeatmapsController < ApplicationController

 before_action :set_heatmap, only: [:show]

  # GET /heatmaps
  def index
    @heatmaps = policy_scope(Heatmap).ordered.page params[:page]
  end

  # GET /heatmaps/1
  def show
  	@days=@heatmap.get_days.keys
  	@times=@heatmap.get_days[@days.first].keys
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_heatmap
      @heatmap = Heatmap.find(params[:id])
      authorize @heatmap
    end
end