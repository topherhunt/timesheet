class Metric < ActiveRecord::Base
  belongs_to :user # TODO: on_delete: :delete_all

  has_many :projects
  has_many :invoices

  validates_presence_of :user_id
  validates_presence_of :label
  validates_inclusion_of :date_filter_type, in: %w(today yesterday this_week this_month since_custom_date)
  validate :_require_custom_date_filter_if_selected
  validates_inclusion_of :operation_type, in: %w(sum sum_minus_commitment)

  def projects
    return [] if project_ids.blank?
    user.projects.where(id: project_ids.split(","))
  end

  def current_total
    scope = user.work_entries
    scope = filter_scope_by_projects(scope)
    scope = filter_scope_by_since(scope)
    scope = run_aggregation(scope)
  end

  def filter_scope_by_projects(scope)
    if projects.any?
      project_ids = projects.map(&:self_and_descendant_ids).flatten.compact.uniq
      scope.where(project_id: project_ids)
    else
      scope
    end
  end

  def filter_scope_by_since(scope)
    case date_filter_type
    when "today" then scope.today
    when "this_week"
      scope = scope.this_week
    when "date"
      scope = scope.started_since(since_custom_date)
    end
  end

  def run_aggregation(scope)
    sql_template = case operation_type
    when "sum" then "SUM([DURATION])"
    when "sum_minus_commitment" then "SUM([DURATION]) - TODO"
    end
    aggregation_sql = sql_template.sub("[DURATION]", WorkEntry.entry_duration_sql)
    scope.select("project_id, invoice_id, #{aggregation_sql} AS aggregation")
  end

  def _require_custom_date_filter_if_selected
    if date_filter_type == "date" && date_filter_since_custom_date.blank?
      errors.add(:base, "Custom date filter must be specified")
    end
  end
end
