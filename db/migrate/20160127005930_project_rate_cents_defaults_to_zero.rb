class ProjectRateCentsDefaultsToZero < ActiveRecord::Migration
  def up
    change_column :projects, :rate_cents, :integer, default: 0
    Project.where('rate_cents IS NULL').update_all(rate_cents: 0)
  end

  def down
  end
end
