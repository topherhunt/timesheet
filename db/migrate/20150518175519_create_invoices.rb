class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.integer :client_id
      t.integer :rate_cents
      t.date :date_start
      t.date :date_end
      t.decimal :total_hours, precision: 4, scale: 2
      t.boolean :is_sent, default: false
      t.boolean :is_paid

      t.timestamps
    end
  end
end
