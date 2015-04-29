class WorkEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :destroy, :stop, :mark_billed]
  before_action :load_projects, only: [:index, :new, :edit]

  def index
    @entries = current_user.work_entries.
      order("created_at DESC").
      paginate(page: params[:page], per_page: 50)

    # TODO: Filter using Ransack
    # client(s), project(s), date_start, date_end, will bill

    if params[:client_id]
      @client  = current_user.clients.find(params[:client_id])
      @entries = @entries.for_client @client
    end

    if params[:project_id]
      @project = current_user.projects.find(params[:project_id])
      @entries = @entries.for_project @project
    end
  end

  def new
    # TODO: Currently this isn't used.
    @entry = current_user.work_entries.new
  end

  def create
    current_user.work_entries.running.each(&:stop!)

    @entry = current_user.work_entries.new(entry_params)

    if @entry.save
      redirect_to work_entries_path, notice: "Entry created successfully."
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @entry.update_attributes(entry_params)
      redirect_to work_entries_path, notice: "Entry updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @entry.destroy!
    render json: { success: true }
  end

  def stop
    @entry.stop!
    render json: { success: true, duration: @entry.duration }
  end

  def mark_billed
    raise "This entry isn't billable!" unless @entry.will_bill?
    @entry.is_billed = true
    @entry.save!

    render json: { success: true }
  end

private

  def entry_params
    params.require(:work_entry).permit(:project_id, :date, :duration, :will_bill, :is_billed, :invoice_notes, :admin_notes)
  end

  def load_entry
    @entry = current_user.work_entries.find(params[:id])
  end

  def load_projects
    @projects = current_user.projects.includes(:client).order("clients.name, projects.name")
  end
end
