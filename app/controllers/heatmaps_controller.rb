class HeatmapsController < ApplicationController

 before_action :set_heatmap, only: [:show]

  # GET /heatmaps
  def index
    @heatmaps = policy_scope(Heatmap).ordered.page params[:page]
  end

  # GET /heatmaps/1
  def show
    @sheared_heatmap = @heatmap.shear_to_opening_hours
  	@days = @sheared_heatmap.keys
  	@times = @sheared_heatmap[@days.second].keys # Use first weekday to set times
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_heatmap
      @heatmap = Heatmap.find(params[:id])
      authorize @heatmap
    end
end