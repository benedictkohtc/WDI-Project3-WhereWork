class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :lat
      t.string :lng
      t.string :icon
      t.string :name
      t.string :google_photo_reference
      t.string :google_rating
      t.string :google_place_id
      t.string :vicinity

      t.timestamps
    end
  end
end


