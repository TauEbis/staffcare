class SpeedsController < ApplicationController

	respond_to :js

	def destroy
    @speed = Speed.find(params[:id])
    authorize @speed
		@speed.location.speeds.destroy(@speed)
    @speed.destroy
    render nothing: true
  end
end