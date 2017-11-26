class RemoveUserStudyFieldsFromUser < ActiveRecord::Migration[5.1]
  def change
		remove_column :users, :participant_number
		remove_column :users, :participant_active
  end
end
