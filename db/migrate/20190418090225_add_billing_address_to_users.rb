class AddBillingAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_address, :text
  end
end
