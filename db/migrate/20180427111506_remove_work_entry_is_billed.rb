class RemoveWorkEntryIsBilled < ActiveRecord::Migration
  def change
    remove_column :work_entries, :is_billed, :boolean, default: false
  end
end
