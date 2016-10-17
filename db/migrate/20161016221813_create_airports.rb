class CreateAirports < ActiveRecord::Migration[5.0]
  def change
    create_table :airports do |t|
      t.string :name
      t.string :symbol
      t.timestamps
    end
  end
end
