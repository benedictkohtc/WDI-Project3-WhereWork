class AddIsWatchedToSavedLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :saved_locations, :is_watched, :boolean, options = { default: false }
  end
end
