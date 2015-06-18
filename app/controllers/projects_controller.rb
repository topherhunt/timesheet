class ProjectsController < ApplicationController
  before_action :authenticate_user!
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

    @clients = current_user.clients.order(:name)
  end

  def create
    # TODO: a malicious user could adjust client_id to attach this project to
    # another user's client, then view that client name. Fix that.
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

  def download
    send_data projects_csv,
      filename: "projects_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
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

  def projects_csv
    require 'csv'

    projects = current_user.projects.
      joins(:client).
      order("clients.name, projects.name")

    CSV.generate do |csv|
      csv << [
        :client,
        :project,
        :created_at,
        :updated_at
      ]

      projects.each do |p|
        csv << [
          p.client.name,
          p.name,
          p.created_at,
          p.updated_at
        ]
      end
    end
  end

end
