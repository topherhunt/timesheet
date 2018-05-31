class AddProjectStartDate < ActiveRecord::Migration
  def up
    add_column :projects, :start_date, :date

    puts "Pre-populating start_date for #{Project.count} projects..."
    Project.reset_column_information
    Project.find_each do |p|
      start_date = p.work_entries.first.try(:started_at) || p.created_at
      p.update!(start_date: start_date)
    end
  end

  def down
    remove_column :projects, :start_date
  end
end
