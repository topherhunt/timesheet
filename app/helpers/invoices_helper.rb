module InvoicesHelper
  def invoice_title
    "Invoice for #{@invoice.project.name} on #{@invoice.date_end}"
  end
end
