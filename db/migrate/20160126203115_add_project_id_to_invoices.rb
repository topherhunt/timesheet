class AddProjectIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :project_id, :integer, after: :client_id
  end
end
