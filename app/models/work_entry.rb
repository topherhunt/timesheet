class WorkEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invoice

  validates :project_id, presence: true
  validates :date,       presence: true

  scope :running,     ->{ where "duration IS NULL" }
  scope :billable,    ->{ where will_bill: true  }
  scope :unbillable,  ->{ where will_bill: false }
  scope :invoiced,    ->{ where "invoice_id IS NOT NULL" }
  scope :uninvoiced,  ->{ where "invoice_id IS NULL"     }

  scope :starting_date, ->(date){ where "date >= ?", date }
  scope :ending_date,   ->(date){ where "date <= ?", date }

  scope :today,     ->{ starting_date(Date.current) }
  scope :this_week, ->{ starting_date(Date.current.beginning_of_week) }

  scope :for_project, ->(project){ where project_id: project.id }
  scope :for_client,  ->(client) { where "project_id IN (?)",
    client.projects.pluck(:id) }

  scope :order_naturally, ->{ order("date DESC, IF(duration IS NULL, 1, 0) DESC, updated_at DESC") }



  def self.total_duration
    all.map{ |entry| entry.duration || entry.pending_duration }.sum
  end



  def stop!
    raise "Entry #{id} is already stopped!" if duration.present?
    self.duration = pending_duration
    save!
  end

  def pending_duration
    ((Time.now - created_at) / 1.hour).round(2)
  end

  def prior_entry
    ids = project.work_entries.order_naturally.pluck(:id)
    next_id = ids[ids.index(self.id) + 1]
    WorkEntry.find_by(id: next_id)
  end
end
