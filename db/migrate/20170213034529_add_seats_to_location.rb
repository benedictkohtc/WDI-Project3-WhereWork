class AddSeatsToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :seats, :integer
    add_column :locations, :sockets, :integer
  end
end
