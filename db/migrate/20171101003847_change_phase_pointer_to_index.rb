class ChangePhasePointerToIndex < ActiveRecord::Migration[5.1]
  def change
		remove_column :phases, :prev_phase_id
		add_column :phases, :phase_index, :integer
  end
end
