class AddLastUpdatedUserToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :last_updated_user, :integer
    add_foreign_key :locations, :users, column: :last_updated_user
  end
end
