class CreatePhases < ActiveRecord::Migration[5.1]
  def change
    create_table :phases do |t|
      t.references :study, foreign_key: true
      t.string :name
      t.references :prev_phase, foreign_key: true

      t.timestamps
    end
  end
end
