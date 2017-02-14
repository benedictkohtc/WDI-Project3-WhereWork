class CreateSavedLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :saved_locations do |t|
      t.references :user, foreign_key: true
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end
