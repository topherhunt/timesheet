class RemoveGoalNotes < ActiveRecord::Migration
  def change
    remove_column :work_entries, :goal_notes, :text
  end
end
