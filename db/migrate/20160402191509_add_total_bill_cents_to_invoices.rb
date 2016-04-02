class AddTotalBillCentsToInvoices < ActiveRecord::Migration
  def up
    add_column :invoices, :total_bill_cents, :integer, after: :total_hours

    # For the invoices that existed prior to this deploy, we can assume the entire
    # project (client) has one rate, so the invoice amount is equal to the
    # duration times the invoice rate. That assumption doesn't hold for invoices
    # created after now though; the total bill can't be confirmed without summing
    # up the hours & rate for each individual entry.
    Invoice.all.each do |invoice|
      invoice.total_bill = Money.new(invoice.rate_cents * invoice.total_hours)
      invoice.save!
    end
  end

  def down
    remove_column :invoices, :total_bill_cents
  end
end
