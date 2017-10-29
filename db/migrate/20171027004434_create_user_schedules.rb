class CreateUserSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :user_schedules do |t|
      t.references :user, foreign_key: true
      t.string :schedule_type
      t.string :time_of_day
      t.integer :day_of_week

      t.timestamps
    end
  end
end
