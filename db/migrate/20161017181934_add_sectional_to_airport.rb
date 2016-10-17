class AddSectionalToAirport < ActiveRecord::Migration[5.0]
  def change
    add_column :airports, :sectional, :string
  end
end
