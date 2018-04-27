module MetricsHelper
  def summarize_metric_operation(metric)
    metric.operation_type.gsub("_", " ").capitalize
  end

  def summarize_metric_projects(metric)
    (metric.projects.any? ? metric.projects.count : "all") + " projects"
  end

  def summarize_metric_since(metric)
    if metric.date_filter_type == "since_custom_date"
      "since #{metric.date_filter_since_custom_date}"
    elsif metric.date_filter_type.nil?
      "across all time"
    else
      metric.date_filter_type.gsub("_", " ")
    end
  end

  def metric_since_options
    [
      ["Today", "today"],
      ["Yesterday", "yesterday"],
      ["This week", "this_week"],
      ["This month", "this_month"],
      ["Since date...", "since_custom_date"]
    ]
  end
end
