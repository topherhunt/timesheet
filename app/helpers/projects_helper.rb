module ProjectsHelper
  def project_options_for_select(opts = {})
    options = []
    options += [[opts[:root].to_s, nil]] if opts[:root]
    Project.top_level.each do |project|
      entries = arrays_for_project_and_children(project, 1, opts)
      options += entries if entries
    end
    # eg. [
    #   ['parent1', 1],
    #   ['  child', 2],
    #   ['parent2', 3],
    #   ['  child', 4] ]

    options_for_select(options, opts[:selected].to_i)
  end

  def arrays_for_project_and_children(project, nesting, opts)
    return nil if opts[:exclude] and opts[:exclude] == project
    return nil if opts[:exclude_inactive] and ! project.active?

    output = [ name_and_id_for_this_project(project, nesting, opts) ]
    project.children.each do |child|
      entries = arrays_for_project_and_children(child, nesting + 1, opts)
      output += entries if entries
    end
    output
    # eg. [ ['parent', 1], ['  child', 2] ]
  end

  def name_and_id_for_this_project(project, nesting, opts)
    name = "#{'&nbsp;&nbsp;' * nesting}#{project.name}"
    if opts[:display_rate] and project.inherited_rate > 0
      name += " (#{project.inherited_rate.format} / hr)"
    end
    [ name.html_safe, project.id ]
  end
end
