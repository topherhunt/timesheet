class AddCreatesValueToWorkEntries < ActiveRecord::Migration
  def change
    add_column :work_entries, :creates_value, :boolean, default: false
  end
end
