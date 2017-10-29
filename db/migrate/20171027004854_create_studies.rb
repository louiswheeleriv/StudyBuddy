class CreateStudies < ActiveRecord::Migration[5.1]
  def change
    create_table :studies do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
