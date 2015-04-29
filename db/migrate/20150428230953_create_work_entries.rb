class CreateWorkEntries < ActiveRecord::Migration
  def change
    create_table :work_entries do |t|
      t.integer :user_id
      t.integer :project_id
      t.date :date
      t.decimal :duration, precision: 4, scale: 2
      t.boolean :will_bill, default: true
      t.boolean :is_billed, default: false
      t.text :invoice_notes
      t.text :admin_notes
      t.timestamps
    end
  end
end
