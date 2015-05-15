class WorkEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :project_id, presence: true
  validates :date,       presence: true

  scope :running,     ->{ where "duration IS NULL" }
  scope :billable,    ->{ where will_bill: true  }

  scope :starting_date, ->(date){ where "date >= ?", date }
  scope :ending_date,   ->(date){ where "date <= ?", date }

  scope :today,     ->{ starting_date(Date.today) }
  scope :this_week, ->{ starting_date(Date.today.beginning_of_week) }

  scope :for_project, ->(project){ where project_id: project.id }
  scope :for_client,  ->(client) { where "project_id IN (?)",
    client.projects.pluck(:id) }



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
end
