class AddRequiresDailyBillingToClients < ActiveRecord::Migration
  def change
    add_column :clients, :requires_daily_billing, :boolean, default: false, after: :rate_cents
  end
end
