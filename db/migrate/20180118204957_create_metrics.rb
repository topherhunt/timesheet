class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.integer :user_id
      t.string :label
      t.string :project_ids
      t.string :statuses
      t.string :date_filter_type
      t.date :date_filter_since_custom_date
      t.string :operation_type
      t.timestamps
    end
  end
end
