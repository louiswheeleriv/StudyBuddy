class CreateUserPhases < ActiveRecord::Migration[5.1]
  def change
    create_table :user_phases do |t|
      t.references :phase, foreign_key: true
      t.references :user, foreign_key: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
