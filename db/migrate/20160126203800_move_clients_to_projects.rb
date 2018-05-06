class MoveClientsToProjects < ActiveRecord::Migration
  def up
    return unless defined?(Client)

    Client.all.each do |client|
      new_project = client.user.projects.create!(
        name: client.name,
        rate_cents: client.rate_cents,
        requires_daily_billing: client.requires_daily_billing,
        parent_id: nil, # top level
        active: true)
      client.invoices.update_all(project_id: new_project.id, client_id: nil)
      client.projects.update_all(parent_id: new_project.id, client_id: nil)

      raise "Client #{client.id} still has projects!" if client.projects.any?
      raise "Client #{client.id} still has invoices!" if client.invoices.any?
      client.destroy!
    end

    raise 'There are still clients left!' if Client.count > 0
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
