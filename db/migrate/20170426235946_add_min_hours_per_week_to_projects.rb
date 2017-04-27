class AddMinHoursPerWeekToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :min_hours_per_week, :decimal, precision: 6, scale: 2
  end
end
