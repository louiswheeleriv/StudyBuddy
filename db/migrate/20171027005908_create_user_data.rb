class CreateUserData < ActiveRecord::Migration[5.1]
  def change
    create_table :user_data do |t|
      t.references :user, foreign_key: true
      t.references :question, foreign_key: true
      t.text :data1
      t.text :data2
      t.text :data3
      t.datetime :answered_at

      t.timestamps
    end
  end
end
