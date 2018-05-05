class RemoveWorkEntryDate < ActiveRecord::Migration
  def change
    remove_column :work_entries, :date, :date
  end
end
