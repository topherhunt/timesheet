class RemoveIsBillableFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :is_billable
  end

  def down
    add_column :projects, :is_billable, :boolean, default: true
  end
end
