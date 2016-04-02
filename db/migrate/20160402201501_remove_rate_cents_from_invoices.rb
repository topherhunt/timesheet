class RemoveRateCentsFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :rate_cents, :integer
  end
end
