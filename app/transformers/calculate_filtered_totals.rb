class CalculateFilteredTotals
  class << self
    def run(filters:, entries:)
      # No need to cache filter results.
      {
        days_in_range: days_in_range(filters: filters, entries: entries),
        total_hours: entries.sum_duration,
        billable_hours: entries.not_excluded.sum_duration,
        value_created: entries.where(creates_value: true).sum_duration * 50,
        per_project: totals_per_project_array(entries: entries)
      }
    end

    private

    def totals_per_project_array(entries:)
      Project
        .where(id: entries.pluck(:project_id).uniq)
        .map { |project| filtered_totals_for_project(project, entries: entries) }
        .sort_by { |h| -h.fetch(:total) }
    end

    def filtered_totals_for_project(project, entries: entries)
      {
        name: project.name_with_ancestry,
        total: entries.where(project_id: project.id).sum_duration
      }
    end

    def days_in_range(filters:, entries:)
      start_date = parse_date(filters[:on_or_after]) ||
        entries.minimum(:started_at).to_date
      end_date = parse_date(filters[:on_or_before]) || Date.current
      end_date - start_date + 1
    end

    def parse_date(date_string)
      date_string.present? ? Time.zone.parse(date_string).to_date : nil
    end
  end
end
