class AddStartedAtToWorkEntries < ActiveRecord::Migration
  def up
    unless WorkEntry.columns.map(&:name).include?("started_at")
      add_column :work_entries, :started_at, :datetime
    end

    # Manually run this data migration:
    # WorkEntry.where(started_at: nil).find_each do |entry|
    #   date_portion = entry.date.beginning_of_day
    #   time_portion = (entry.created_at - entry.created_at.beginning_of_day)
    #   entry.update!(started_at: date_portion + time_portion)
    # end
  end

  def down
    remove_column :work_entries, :started_at
  end
end
