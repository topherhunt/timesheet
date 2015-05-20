class AddIsInvoicedToWorkEntries < ActiveRecord::Migration
  def change
    add_column :work_entries, :invoice_id, :integer, after: :is_billed
  end
end
