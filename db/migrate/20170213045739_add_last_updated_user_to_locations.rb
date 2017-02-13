class AddLastUpdatedUserToLocations < ActiveRecord::Migration[5.0]
  def change
    add_reference :locations, :last_updated_user, foreign_key: true
  end
end
