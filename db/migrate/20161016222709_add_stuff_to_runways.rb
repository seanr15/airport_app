class AddStuffToRunways < ActiveRecord::Migration[5.0]
  def change
    add_reference :runways, :airport, foreign_key: true
    add_column :runways, :name, :string
    add_column :runways, :number, :string
    add_column :runways, :dimensions, :string
    add_column :runways, :surface, :string
    add_column :runways, :weight_limits, :string
    add_column :runways, :edge_lighting, :string
    add_column :runways, :coordinates, :string
    add_column :runways, :elevation, :string
    add_column :runways, :gradient, :string
    add_column :runways, :traffic_pattern, :string
    add_column :runways, :runway_heading, :string
    add_column :runways, :displaced_threshold, :string
    add_column :runways, :markings, :string
    add_column :runways, :glide_slope_indicator, :string
    add_column :runways, :reil, :string
    add_column :runways, :obstacles, :string
    add_column :runways, :declared_distances, :string
    add_column :runways, :approach_lights, :string
    add_column :runways, :rvr_equipment, :string
    add_column :runways, :centerline_lights, :string
  end
end
