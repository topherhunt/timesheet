module ProjectsHelper
  def project_options_for_select(kwargs)
    options = ProjectOptionsBuilder.new(current_user: @current_user, **kwargs).run
    options_for_select(options, kwargs[:selected_id].to_i)
  end
end
