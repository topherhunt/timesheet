class TotalsPerProjectCalculator
  def initialize(user:)
    @user = user
  end

  def run
    Cacher.fetch("user_#{@user.id}_totals_per_project", expires_in: 1.hour) do
      all_projects
        .map { |project| totals_for_project(project) }
        .reject { |h| h.fetch(:week_total) == 0 && h.fetch(:weekly_target) == 0 }
        .sort_by { |h| h.fetch(:name) }
    end
  end

  private

  def all_projects
    (@user.projects.roots + @user.projects.where("weekly_target > 0")).uniq
  end

  # Makes 3 SQL queries per project. The "today" and "this week" queries could
  # be aggregated, but it's tedious, and I don't see a clean way to aggregate the
  # "total since start date" queries because a project can inherit start_date.
  def totals_for_project(project)
    {
      name: project.name,
      today_total: WorkEntry.in_project(project).not_excluded.today.sum_duration,
      week_total: WorkEntry.in_project(project).not_excluded.this_week.sum_duration,
      weekly_target: project.weekly_target || 0,
      weekly_average: project.weekly_avg_since_start
    }
  end
end
