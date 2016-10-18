class AddTypeToAirport < ActiveRecord::Migration[5.0]
  def change
    add_column :airports, :airport_type, :string
  end
end
