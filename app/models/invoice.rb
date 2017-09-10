class Invoice < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  has_many :work_entries, dependent: :nullify
  has_many :projects, through: :work_entries

  validates :project_id,  presence: true
  validates :date_start, presence: true
  validates :date_end,   presence: true
  validates :total_hours, presence: true
  validates :total_bill, presence: true

  monetize :total_bill_cents

  def eligible_entries
    WorkEntry.where(project: project.self_and_descendants)
      .billable
      .uninvoiced
      .starting_date(date_start)
      .ending_date(date_end)
  end
end
