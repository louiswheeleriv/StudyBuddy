class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.references :phase, foreign_key: true
      t.integer :hour_offset
      t.integer :every_n_days
      t.text :question_text
      t.string :answer_type

      t.timestamps
    end
  end
end
