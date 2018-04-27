module ProjectsHelper
  def project_options_for_select(kwargs)
    options = ProjectOptionsBuilder.new(current_user: @current_user, **kwargs).run
    selections = [kwargs[:selected_id]].flatten.map(&:to_i)
    options_for_select(options, selections)
  end
end
