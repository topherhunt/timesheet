class ProjectOptionsBuilder
  def initialize(
    current_user:,
    selected_id: nil,
    exclude_id: nil,
    exclude_inactive: false,
    display_rate: false,
    root: nil
  )
    @current_user = current_user
    @selected_id = selected_id
    @exclude_id = exclude_id
    @exclude_inactive = exclude_inactive
    @display_rate = display_rate
    @root = root
  end

  def run
    projects_hash = @current_user.projects.hash_tree
    projects_array = hash_to_flat_array(projects_hash)
    options = render_options(projects_array)
    options = [[@root.to_s, nil]] + options if @root.present?
    options
  end

  def hash_to_flat_array(hash)
    hash.map do |project, children|
      next if excluded_directly?(project)
      next if excluded_because_inactive?(project)
      [project, hash_to_flat_array(children)]
    end.flatten.compact
  end

  def excluded_directly?(project)
    @exclude_id.to_i == project.id
  end

  def excluded_because_inactive?(project)
    @exclude_inactive == true && ! project.active? && @selected_id.to_i != project.id
  end

  def render_options(projects_array)
    projects_array.map do |project|
      name = project.name_with_ancestry
      name += " (#{project.rate.format} / hr)" if display_rate?(project)
      [name.html_safe, project.id]
    end
      .sort_by{ |option| option[0] }
  end

  def display_rate?(project)
    @display_rate && project.rate > 0
  end
end
