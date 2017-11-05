class MakePrevPhaseOptional < ActiveRecord::Migration[5.1]
  def change
		change_column_null :phases, :prev_phase_id, true
  end
end
