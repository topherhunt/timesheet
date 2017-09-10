class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    projects_as_hash = current_user.projects.hash_tree
    @projects = hash_to_flat_array(projects_as_hash)

    # @top_level_projects = current_user.projects.roots.order(:name)
  end

  def new
    @project = current_user.projects.new(parent_id: params[:parent_id])
  end

  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      Cacher.delete_matched("user_#{current_user.id}_")
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
      Cacher.delete_matched("user_#{current_user.id}_")
      redirect_to projects_path, notice: "Project \"#{@project.name}\" updated successfully."
    else
      render 'edit'
    end
  end

  def show
    load_project
    @children = hash_to_flat_array(@project.children.hash_tree)
  end

  def destroy
    load_project

    if @project.children.any? or @project.work_entries.any?
      redirect_to edit_project_path(@project), alert: "Can't delete project \"#{@project.name}\" because it contains child projects or work entries."
    else
      @project.destroy!
      Cacher.delete_matched("user_#{current_user.id}_")
      redirect_to projects_path, notice: "Project \"#{@project.name}\" deleted successfully."
    end
  end

private

  def project_params
    params.require(:project).permit(:name, :parent_id, :rate, :requires_daily_billing, :active, :min_hours_per_week)
  end

  def load_project
    @project = current_user.projects.find(params[:id])
  end

  def hash_to_flat_array(hash)
    hash.map do |project, children|
      next unless project.active? or params[:show_inactive].present?
      [project, hash_to_flat_array(children)]
    end
      .flatten
      .compact
      .sort_by(&:name_with_ancestry)
  end
end
