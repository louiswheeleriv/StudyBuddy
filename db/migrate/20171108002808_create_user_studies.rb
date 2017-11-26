class CreateUserStudies < ActiveRecord::Migration[5.1]
  def change
    create_table :user_studies do |t|
      t.references :user, foreign_key: true
      t.references :study, foreign_key: true
      t.string :participant_number
      t.boolean :participant_active

      t.timestamps
    end
  end
end
