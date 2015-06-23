class AddGoalNotesToWorkEntries < ActiveRecord::Migration
  def change
    add_column :work_entries, :goal_notes, :text, after: :invoice_id
  end
end
