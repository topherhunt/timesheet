class WorkEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, presence: true
  validates :date,       presence: true

  scope :running,     ->{ where "duration IS NULL" }
  scope :billable,    ->{ where will_bill: true  }

  scope :starting_date, ->(date){ where "date >= ?", date }
  scope :ending_date,   ->(date){ where "date <= ?", date }

  scope :for_project, ->(project){ where project_id: project.id }
  scope :for_client,  ->(client) { where "project_id IN (?)",
    client.projects.pluck(:id) }

  def stop!
    raise "Entry #{id} is already stopped!" if duration.present?
    self.duration = pending_duration
    save!
  end

  def pending_duration
    duration || ((Time.now - created_at) / 1.hour).round(2)
  end
end
