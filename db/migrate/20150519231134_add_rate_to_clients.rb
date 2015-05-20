class AddRateToClients < ActiveRecord::Migration
  def change
    add_column :clients, :rate_cents, :integer, after: :name
  end
end
