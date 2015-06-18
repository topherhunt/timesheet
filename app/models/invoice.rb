class Invoice < ActiveRecord::Base
  belongs_to :user
  belongs_to :client

  has_many :work_entries, dependent: :nullify

  validates :client_id,  presence: true
  validates :date_start, presence: true
  validates :date_end,   presence: true

  monetize :rate_cents

  def eligible_entries
    user.work_entries.billable.
      for_client(client).
      starting_date(date_start).
      ending_date(date_end).
      where("invoice_id IS NULL")
  end
end
