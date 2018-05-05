require 'csv'

class CsvGenerator
  def self.invoices_csv(user)
    CSV.generate do |csv|
      csv << [
        :id,
        :project,
        :date_start,
        :date_end,
        :total_hours,
        :total_bill,
        :num_work_entries,
        :is_sent,
        :is_paid,
        :created_at,
        :updated_at
      ]

      user.invoices.includes(:project).order("created_at DESC").each do |i|
        csv << [
          i.id,
          i.project.name,
          i.date_start,
          i.date_end,
          i.total_hours,
          i.total_bill.format,
          i.work_entries.count,
          i.is_sent,
          i.is_paid,
          i.created_at,
          i.updated_at
        ]
      end
    end
  end

  def self.work_entries_csv(user)
    CSV.generate do |csv|
      csv << [
        :id,
        :project,
        :started_at,
        :duration,
        :exclude_from_invoice,
        :invoice_id,
        :invoice_notes,
        :admin_notes,
        :created_at,
        :updated_at
      ]

      user.work_entries.includes(:project).order_naturally.each do |e|
        csv << [
          e.id,
          e.project.name_with_ancestry,
          e.started_at,
          e.duration,
          e.exclude_from_invoice,
          e.invoice_id,
          e.invoice_notes,
          e.admin_notes,
          e.created_at,
          e.updated_at
        ]
      end
    end
  end
end
