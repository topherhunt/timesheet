class FixInvoicesFloatsToLargerMaximum < ActiveRecord::Migration
  def change
    change_column :invoices, :total_hours, :decimal, precision: 6, scale: 2
  end
end
