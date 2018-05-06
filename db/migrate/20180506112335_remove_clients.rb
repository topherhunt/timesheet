class RemoveClients < ActiveRecord::Migration
  def up
    drop_table :clients
    remove_column :projects, :client_id
  end

  def down
    create_table "clients", force: :cascade do |t|
      t.integer  "user_id",                limit: 4
      t.string   "name",                   limit: 255
      t.integer  "rate_cents",             limit: 4
      t.boolean  "requires_daily_billing",             default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_column :projects, :client_id, :integer
  end
end
