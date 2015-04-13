class ProjectsController < ApplicationController
  before_action :load_client_if_scoped,   only: [:index, :new]
  before_action :load_project_and_client, only: [:edit, :update, :show]


  def index
    @projects = current_user.projects.
      joins(:client).order("clients.name, projects.name")

    @projects = @projects.where(client_id: @client.id) if @client
  end

  def new
    @project = current_user.projects.new
    @project.client_id = @client.id if @client

    @clients = current_user.clients
  end

  def create
    # TODO: a malicious user could adjust client_id to attach this project to
    # another user's client, then view that client name.
    @project = current_user.projects.new(project_params)

    if @project.save
      redirect_to projects_path, notice: "Project created successfully."
    else
      render 'new'
    end
  end

  def edit
    @clients = current_user.clients
  end

  def update
    if @project.update_attributes(project_params)
      redirect_to projects_path, notice: "Project updated successfully."
    else
      render 'edit'
    end
  end

  def show
  end

private

  def project_params
    params.require(:project).permit(:name, :client_id)
  end

  def load_client_if_scoped
    @client = current_user.clients.find(params[:client_id]) if params[:client_id]
  end

  def load_project_and_client
    @project = current_user.projects.find(params[:id])
    @client  = @project.client
  end
end
