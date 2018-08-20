class CalculateUnfilteredTotals
  class << self
    def run(user:)
      Cacher.fetch("user_#{user.id}_totals_per_project", expires_in: 15.minutes) do
        {
          per_project: totals_per_project_array(user: user),
          value_created: value_created_totals(user: user)
        }
      end
    end

    private

    def value_created_totals(user:)
      entries = user.work_entries.where(creates_value: true)
      {
        today: entries.today.sum_duration * 50,
        week: entries.this_week.sum_duration * 50
      }
    end

    def totals_per_project_array(user:)
      all_projects(user: user)
        .map { |project| totals_for_project(project) }
        .reject { |h| h.fetch(:week_total) == 0 && h.fetch(:weekly_target) == 0 }
        .sort_by { |h| h.fetch(:name) }
    end

    def all_projects(user:)
      (user.projects.roots + user.projects.where("weekly_target > 0")).uniq
    end

    # Makes 3 SQL queries per project. The "today" and "this week" queries could
    # be aggregated, but it's tedious, and I don't see a clean way to aggregate the
    # "total since start date" queries because a project can inherit start_date.
    def totals_for_project(project)
      entries = WorkEntry.in_project(project)
      {
        name: project.name,
        start_date: project.start_date,
        today_total: entries.not_excluded.today.sum_duration,
        week_total: entries.not_excluded.this_week.sum_duration,
        weekly_target: project.weekly_target || 0,
        weekly_average: project.weekly_avg_since_start
      }
    end
  end
end
