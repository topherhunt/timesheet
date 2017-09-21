class WorkEntriesFilter
  def initialize(current_user, entries, filters)
    @current_user = current_user
    @entries = entries
    @filters = filters
  end

  def run
    if @filters[:project_id].present?
      project = @current_user.projects.find(@filters[:project_id])
      @entries = @entries.in_project(project)
    end

    if @filters[:date_start].present?
      @entries = @entries.starting_date(@filters[:date_start])
    end

    if @filters[:date_end].present?
      @entries = @entries.ending_date(@filters[:date_end])
    end

    if @filters[:status].present?
      # TODO: Support other status filter options
      case @filters[:status]
      when "unbillable" then @entries = @entries.unbillable
      else raise "Unknown status filter '#{@filters[:status]}'!"
      end
    end

    if @filters[:duration_min].present?
      @entries = @entries.where('duration >= ?', @filters[:duration_min])
    end

    if @filters[:duration_max].present?
      @entries = @entries.where('duration <= ?', @filters[:duration_max])
    end

    if @filters[:memo_contains].present?
      s = "%#{@filters[:memo_contains]}%"
      @entries = @entries.where("invoice_notes LIKE ? OR admin_notes LIKE ?", s, s)
    end

    @entries
  end
end
