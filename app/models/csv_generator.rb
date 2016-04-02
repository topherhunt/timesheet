require 'csv'

class CsvGenerator
  def self.projects_csv(user)
    CSV.generate do |csv|
      csv << [
        :parent,
        :project,
        :created_at,
        :updated_at
      ]

      user.projects.order('parent_id, name').each do |p|
        # TODO: This will lead to n+1 queries
        csv << [
          "#{p.parent.name} (#{p.parent.id})",
          "#{p.name} #{p.id}",
          p.created_at,
          p.updated_at
        ]
      end
    end
  end

  def self.invoices_csv(user)
    CSV.generate do |csv|
      csv << [
        :id,
        :project,
        :rate,
        :date_start,
        :date_end,
        :total_hours,
        :num_work_entries,
        :is_sent,
        :is_paid,
        :created_at,
        :updated_at
      ]

      user.invoices.order(:created_at).each do |i|
        csv << [
          i.id,
          i.project.name,
          i.rate.format,
          i.date_start,
          i.date_end,
          i.total_hours,
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
        :date,
        :duration,
        :will_bill,
        :is_billed,
        :invoice_id,
        :invoice_notes,
        :admin_notes,
        :created_at,
        :updated_at
      ]

      user.work_entries.order_naturally.each do |e|
        csv << [
          e.id,
          e.project.name_with_ancestry,
          e.date,
          e.duration,
          e.will_bill,
          e.is_billed,
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
