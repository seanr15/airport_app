class AddSearchTermToAirports < ActiveRecord::Migration[5.0]
  def change
    add_column :airports, :search_term, :string
  end
end
