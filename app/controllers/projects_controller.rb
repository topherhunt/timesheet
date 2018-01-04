class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    projects_hash = current_user.projects.hash_tree
    @projects = hash_to_flat_array(projects_hash, show_inactive: params[:show_inactive])
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
    @project = load_project
  end

  def update
    @project = load_project
    if @project.update_attributes(project_params)
      Cacher.delete_matched("user_#{current_user.id}_")
      redirect_to projects_path, notice: "Project \"#{@project.name}\" updated successfully."
    else
      render 'edit'
    end
  end

  def show
    @project = load_project
    @children = hash_to_flat_array(@project.children.hash_tree)
  end

  def delete
    @project = load_project
  end

  def destroy
    @project = load_project
    @move_to_project = current_user.projects.find_by(id: params[:move_to_project_id])
    if @move_to_project.blank? || @move_to_project.self_and_ancestors.pluck(:id).include?(@project.id)
      raise "User #{current_user.id} just tried to delete project #{@project.id} and move its data to project #{params[:move_to_project_id]}, but that's an invalid action!"
    end

    @project.children.each{ |project| project.update!(parent_id: @move_to_project.id) }
    @project.work_entries.update_all(project_id: @move_to_project.id)
    @project.invoices.update_all(project_id: @move_to_project.id)

    @project.destroy!
    Cacher.delete_matched("user_#{current_user.id}_")
    redirect_to projects_path, notice: "Project \"#{@project.name_with_ancestry}\" has been removed. All data was moved to project \"#{@move_to_project.name_with_ancestry}\"."
  end

  private

  def project_params
    params.require(:project).permit(:name, :parent_id, :rate, :requires_daily_billing, :active, :min_hours_per_week)
  end

  def load_project
    current_user.projects.find(params[:id])
  end

  def hash_to_flat_array(hash, opts = {})
    hash.map do |project, children|
      next unless project.active? or opts[:show_inactive].present?
      [project, hash_to_flat_array(children, opts)]
    end
      .flatten
      .compact
      .sort_by(&:name_with_ancestry)
  end
end
