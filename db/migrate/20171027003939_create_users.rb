class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.boolean :is_admin
      t.string :participant_number
      t.boolean :participant_active
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :password
      t.string :email
      t.string :phone
      t.string :timezone

      t.timestamps
    end
  end
end
