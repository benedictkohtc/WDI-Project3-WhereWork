class CreateOpeningtimes < ActiveRecord::Migration[5.0]
  def change
    create_table :openingtimes do |t|
      t.belongs_to :location, foreign_key: true
      t.string :day
      t.time :opening_time
      t.time :closing_time

      t.timestamps
    end
  end
end
