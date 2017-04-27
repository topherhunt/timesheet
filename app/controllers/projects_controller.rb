class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @top_level_projects = current_user.projects.top_level.order(:name)
  end

  def new
    @project = current_user.projects.new(parent_id: params[:parent_id])
  end

  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to projects_path, notice: "Project created successfully."
    else
      render 'new'
    end
  end

  def edit
    load_project
  end

  def update
    load_project
    if @project.update_attributes(project_params)
      Rails.cache.clear # clear out cached metrics so they're regenerated next time the user views the timesheet
      redirect_to projects_path, notice: "Project \"#{@project.name}\" updated successfully."
    else
      render 'edit'
    end
  end

  def show
    load_project
  end

  def destroy
    load_project

    if @project.children.any? or @project.work_entries.any?
      redirect_to edit_project_path(@project), alert: "Can't delete project \"#{@project.name}\" because it contains child projects or work entries."
    else
      @project.destroy!
      redirect_to projects_path, notice: "Project \"#{@project.name}\" deleted successfully."
    end
  end

  def download
    send_data CsvGenerator.projects_csv(current_user),
      filename: "projects_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
  end

private

  def project_params
    params.require(:project).permit(:name, :parent_id, :rate, :requires_daily_billing, :active, :min_hours_per_week)
  end

  def load_project
    @project = current_user.projects.find(params[:id])
  end
end
