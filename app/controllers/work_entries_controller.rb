class WorkEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :destroy, :stop]
  before_action :load_projects_and_clients, only: [:index, :new, :edit]
  before_action :prepare_filter, only: :index

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
    @entry.will_bill = project.client.rate.present? ? true : false

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
      if request.xhr?
        render json: { success: true }
      else
        redirect_to work_entries_path
      end
    else
      render 'edit'
    end
  end

  def stop
    @entry.stop!
    redirect_to work_entries_path
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

    redirect_to work_entries_path, notice: "Merged entries #{@from.id} and #{@to.id}."
  end

  def destroy
    @entry.destroy!
    render json: { success: true }
  end

  def download
    send_data entries_csv,
      filename: "work_entries_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
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

  def prepare_filter
    @filters = {}

    if params[:filter]
      puts "Filter submitted."
      @filters = params
      cookies[:filter] = @filters.to_json
    elsif params[:clear_filter]
      puts "Filter cleared."
      cookies.delete :filter
    elsif cookies[:filter]
      puts "Filter fetched from cookie."
      @filters = JSON.parse(cookies[:filter]).symbolize_keys
    end
  end

  def filter_entries
    return unless @filters.any?

    puts "Filter present."

    if @filters[:client_id].present?
      puts "Filtering by client id #{@filters[:client_id]}"
      @client  = current_user.clients.find(@filters[:client_id])
      @entries = @entries.for_client @client
    end

    if @filters[:project_id].present?
      @project = current_user.projects.find(@filters[:project_id])
      @entries = @entries.for_project @project
    end

    if @filters[:date_start].present?
      @date_start = @filters[:date_start]
      @entries = @entries.starting_date @date_start
    end

    if @filters[:date_end].present?
      @date_end = @filters[:date_end]
      @entries = @entries.ending_date @date_end
    end
  end

  def calculate_totals
    if @filters.any?
      @hrs_total    = @entries.         total_duration
      @hrs_billable = @entries.billable.total_duration
    else
      @hrs_total_today        = @entries.today.             total_duration
      @hrs_billable_today     = @entries.today.billable.    total_duration
      @hrs_total_this_week    = @entries.this_week.         total_duration
      @hrs_billable_this_week = @entries.this_week.billable.total_duration
    end
  end

  def entries_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [
        :id,
        :project,
        :client,
        :date,
        :duration,
        :will_bill,
        :is_billed,
        :invoice_id,
        :invoice_notes,
        :admin_notes,
        :created_at,
        :updated_at
      ]

      current_user.work_entries.order_naturally.each do |e|
        csv << [
          e.id,
          e.project.name,
          e.project.client.name,
          e.date,
          e.duration,
          e.will_bill,
          e.is_billed,
          e.invoice_id,
          e.invoice_notes,
          e.admin_notes,
          e.created_at,
          e.updated_at
        ]
      end
    end
  end

end
