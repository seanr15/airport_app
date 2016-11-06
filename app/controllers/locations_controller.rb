class LocationsController < ApplicationController
  before_action :set_location

  def show
    puts @location
    puts params.inspect
    respond_to do |format|
      format.html
      format.json { render json: @location.airports.order(:name) }

    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def location_params
    params.fetch(:location, {})
  end
end
