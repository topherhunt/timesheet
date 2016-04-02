class MakeProjectsNestable < ActiveRecord::Migration
  def change
    add_column :projects, :parent_id, :integer, after: :client_id
    add_column :projects, :rate_cents, :integer, after: :active
    add_column :projects, :requires_daily_billing, :integer, after: :rate_cents
  end
end
