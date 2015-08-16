module WorkEntriesHelper
  def grouped_project_options(projects)
    keyed_projects = projects.each_with_object({}) do |project, hash|
      client = project.client.name
      hash[client] ||= []
      hash[client] << [project.name, project.id]
    end
    # result: { client: [projects], client: [projects] }

    grouped_projects = keyed_projects.map{ |key, projects| [key, projects] }
    # result: [ [client, [projects]], [client, [projects]] ]
  end
end
