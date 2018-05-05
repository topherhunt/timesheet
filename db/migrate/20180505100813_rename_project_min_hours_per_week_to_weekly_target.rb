class RenameProjectMinHoursPerWeekToWeeklyTarget < ActiveRecord::Migration
  def change
    rename_column :projects, :min_hours_per_week, :weekly_target
  end
end
