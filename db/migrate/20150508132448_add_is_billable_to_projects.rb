class AddIsBillableToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_billable, :boolean, default: true, after: :name
  end
end
