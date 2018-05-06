class MigrateWillBillToExcludeFromInvoice < ActiveRecord::Migration
  def up
    add_column :work_entries, :exclude_from_invoice, :boolean, default: false

    billable_projects.each do |project|
      entries_to_exclude = WorkEntry.in_project(project).where(will_bill: false)
      puts "Billable project #{project.id} (#{project.name}): Excluding #{entries_to_exclude.count} entries from invoice."
      entries_to_exclude.update_all(exclude_from_invoice: true)
    end

    remove_column :work_entries, :will_bill
  end

  def down
    add_column :work_entries, :will_bill, :boolean, default: false

    billable_projects.each do |project|
      all_entries = WorkEntry.in_project(project)
      unbillable_entries = all_entries.where(exclude_from_invoice: true)
      puts "Billable project #{project.id} (#{project.name}): Marking all #{all_entries.count} entries as billable, except for #{unbillable_entries.count} entries which were excluded from the invoice."
      all_entries.update_all(will_bill: true)
      unbillable_entries.update_all(will_bill: false)
    end

    remove_column :work_entries, :exclude_from_invoice
  end

  private

  def billable_projects
    Project.where("rate_cents > 0")
  end
end
