class WorkEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :invoice

  validates :project_id, presence: true
  validates :date,       presence: true

  scope :running,     ->{ where "duration IS NULL" }
  scope :billable,    ->{ where will_bill: true  }
  scope :unbillable,  ->{ where will_bill: false }
  scope :unbilled,    ->{ where is_billed: false }
  scope :invoiced,    ->{ where "invoice_id IS NOT NULL" }
  scope :uninvoiced,  ->{ where "invoice_id IS NULL"     }
  scope :old,         ->{ where "date < ?", Time.zone.now.to_date }
  scope :starting_date, ->(date){ where "date >= ?", date }
  scope :ending_date,   ->(date){ where "date <= ?", date }
  scope :today,     ->{ starting_date(Time.zone.now.to_date) }
  scope :this_week, ->{ starting_date(Time.zone.now.beginning_of_week.to_date) }
  scope :in_project, ->(project){ where(project_id: project.my_and_children_ids) }

  scope :order_naturally, ->{ order("date DESC, IF(duration IS NULL, 1, 0) DESC, created_at DESC") }

  before_save :process_newlines



  def self.total_duration
    all.map{ |entry| entry.duration || entry.pending_duration }.sum
  end



  def stop!
    raise "Entry #{id} is already stopped!" if duration.present?
    self.duration = pending_duration
    save!
  end

  def eligible_for_merging?
    prior_entry and duration and invoice_id.nil? and prior_entry.invoice_id.nil?
  end

  def merge!(from)
    self.duration     += from.duration
    self.invoice_notes = merge_strings invoice_notes, from.invoice_notes
    self.admin_notes   = merge_strings admin_notes,   from.admin_notes

    # date, invoice_id, and billing settings aren't changed
    save!
  end

  def merge_strings(string1, string2)
    "#{string1}\t #{string2}".strip.sub("\t", ";")
  end

  def pending_duration
    ((Time.now - created_at) / 1.hour).round(2)
  end

  def bill
    duration * project.inherited_rate
  end

  def prior_entry
    ids = project.work_entries.
      where(will_bill: will_bill).
      where(is_billed: is_billed).
      order_naturally.pluck(:id)
    prior_id = ids[ids.index(self.id) + 1] or return
    WorkEntry.find_by(id: prior_id)
  end

  def process_newlines
    self.invoice_notes = invoice_notes.strip.gsub(/[\r\n\t]+/, "; ").gsub(/\s\s+/, " ")
    self.admin_notes   = admin_notes  .strip.gsub(/[\r\n\t]+/, "; ").gsub(/\s\s+/, " ")
  end

  def billing_status_term
    if will_bill
      is_billed ? "billed" : "billable"
    else
      "unbillable"
    end
  end
end
