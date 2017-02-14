class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :lat
      t.string :lng
      t.string :icon
      t.string :name
      t.string :google_photo_reference
      t.string :cloudinary_link
      t.string :google_rating
      t.string :google_place_id
      t.string :vicinity
      t.integer :total_sockets
      t.integer :available_sockets
      t.integer :total_seats
      t.integer :available_seats
      t.boolean :coffee
      t.boolean :quiet
      t.boolean :wifi
      t.string :wifi_name
      t.string :wifi_password
      t.boolean :aircon
      t.timestamps
    end
  end
end


