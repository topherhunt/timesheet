class WorkEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :destroy, :stop, :mark_billed]
  before_action :load_projects_and_clients, only: [:index, :new, :edit]

  def index
    @entries = current_user.work_entries.order_naturally

    filter_entries

    calculate_totals

    # Pagination must wait until after totals are calculated
    @entries = @entries.paginate(page: params[:page], per_page: 50)

    # Determines which favicon will show in the tabs bar
    @timer_running = true if current_user.work_entries.running.any?
  end

  def create
    @entry = current_user.work_entries.new(entry_params)
    @entry.date ||= Date.current

    project = current_user.projects.find(params[:work_entry][:project_id])
    @entry.will_bill = true if project.client.rate.present?

    if @entry.save
      if params[:commit] == "Create and edit"
        redirect_to edit_work_entry_path(@entry)
      else
        redirect_to work_entries_path
      end
    else
      render 'new'
    end
  end

  def edit
    @prior_entry = @entry.prior_entry
  end

  def update
    if @entry.update_attributes(entry_params)
      redirect_to work_entries_path, notice: "Entry updated successfully."
    else
      render 'edit'
    end
  end

  def merge
    @from = current_user.work_entries.find(params[:from])
    @to   = current_user.work_entries.find(params[:to])

    @to.duration += @from.duration
    @to.invoice_notes = "#{@to.invoice_notes} #{@from.invoice_notes}".strip
    @to.admin_notes   = "#{@to.admin_notes} #{@from.admin_notes}"    .strip

    # The date, invoice_id, and billing settings on the TO entry aren't changed

    @to.save!
    @from.destroy!

    redirect_to work_entries_path, notice: "Entry on #{@from.date} merged successfully."
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

  def load_entry
    @entry = current_user.work_entries.find(params[:id])
  end

  def load_projects_and_clients
    @projects = current_user.projects.includes(:client).order("clients.name, projects.name")
    @clients  = current_user.clients.order(:name)
  end

  def entry_params
    params.require(:work_entry).permit(:project_id, :date, :duration, :will_bill, :is_billed, :invoice_notes, :admin_notes)
  end

  def filter_entries
    if params[:client_id].present?
      @client  = current_user.clients.find(params[:client_id])
      @entries = @entries.for_client @client
    end

    if params[:project_id].present?
      @project = current_user.projects.find(params[:project_id])
      @entries = @entries.for_project @project
    end

    if params[:date_start].present?
      @date_start = params[:date_start]
      @entries = @entries.starting_date @date_start
    end

    if params[:date_end].present?
      @date_end = params[:date_end]
      @entries = @entries.ending_date @date_end
    end
  end

  def calculate_totals
    if params[:filter]
      @hrs_total    = @entries.         total_duration
      @hrs_billable = @entries.billable.total_duration
    else
      @hrs_total_today        = @entries.today.             total_duration
      @hrs_billable_today     = @entries.today.billable.    total_duration
      @hrs_total_this_week    = @entries.this_week.         total_duration
      @hrs_billable_this_week = @entries.this_week.billable.total_duration
    end
  end

end
