class WorkEntriesController < ApplicationController
  include DateHelper

  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :stop, :destroy, :stop, :show]

  def index
    @entries = current_user.work_entries
    @filters = prepare_filters
    @entries = WorkEntriesFilter.new(current_user, @entries, @filters).run
    @totals = calculate_totals
    # Pagination, sorting, and includes come after totals are calculated
    @entries = @entries
      .order_naturally
      .includes(:project, :invoice)
      .paginate(page: params[:page], per_page: 50)
    # Determines which favicon will show in the tabs bar
    @timer_running = true if current_user.work_entries.running.any?
  end

  def create
    project = current_user.projects.find(params[:work_entry][:project_id])
    @entry = current_user.work_entries.create!(create_params.merge(
      started_at: Time.current,
      will_bill: project.billable?
    ))
    current_user.work_entries.running.where("id != ?", @entry.id).each(&:stop!)

    if params.key?("submit_edit")
      redirect_to edit_work_entry_path(@entry)
    else
      redirect_to work_entries_path
    end
  end

  # Handles GET request that can result from refreshing a failed #update
  def show
    redirect_to edit_work_entry_path(@entry)
  end

  def edit
  end

  def update
    if @entry.update_attributes(update_params)
      redirect_to work_entries_path
    else
      render 'edit'
    end
  end

  def stop
    @entry.stop!
    redirect_to work_entries_path
  end

  def prior_entry
    load_entry
    if e = @entry.prior_entry
      render json: {
        entry_id: e.id,
        status: e.will_bill ? "billable" : "unbillable",
        project_name: e.project.name,
        started_at_date: date(e.started_at, weekday: true, time: true),
        duration: e.duration
      }
    else
      render json: {none_found: true}
    end
  end

  def merge
    @from = current_user.work_entries.find(params[:from])
    @to   = current_user.work_entries.find(params[:to])

    unless @from.eligible_for_merging? and @from.prior_entry == @to
      raise "Entry #{@from.id} isn't eligible to merge with entry #{@to.id}!"
    end

    @to.merge! @from
    @from.destroy!

    redirect_to work_entries_path, notice: "Merged entries #{@from.id} & #{@to.id}."
  end

  def destroy
    @entry.destroy!
    redirect_to work_entries_path, notice: "Deleted entry #{@entry.id}."
  end

  def download
    send_data CsvGenerator.work_entries_csv(current_user),
      filename: "work_entries_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
  end

private

  def load_entry
    @entry = current_user.work_entries.find(params[:id])
  end

  def create_params
    params.require(:work_entry).permit(:project_id, :invoice_notes)
  end

  def update_params
    params.require(:work_entry)
      .permit(:project_id, :duration, :will_bill, :invoice_notes, :admin_notes)
      .merge(started_at: compose_started_at_from_params)
  end

  def compose_started_at_from_params
    p = params[:work_entry]
    date = Time.zone.parse(p[:started_at_date])
    time = Time.zone.parse(p[:started_at_time])
    raise("Don't know how to parse #{p[:started_at_date].inspect} into a date!") if date.nil?
    raise("Don't know how to parse #{p[:started_at_time].inspect} into a time!") if time.nil? or (time - time.beginning_of_day == 0)
    date + (time - time.beginning_of_day)
  end

  def prepare_filters
    case
    when params[:filter].present?
      cookies[:filter] = { value: params.to_json, expires: 1.hour.from_now }
      params
    when params[:clear_filter].present?
      cookies.delete(:filter)
      {}
    when cookies[:filter].present?
      JSON.parse(cookies[:filter]).symbolize_keys
    else
      {}
    end
  end

  def calculate_totals
    if @filters.any?
      {
        filtered: {
          total: @entries.sum_duration,
          billable: @entries.billable.sum_duration
        }
      }
    else
      {
        projects: current_user.projects.roots.map do |pr|
          {
            name: pr.name,
            today_total: @entries.in_project(pr).today.sum_duration,
            week_total: @entries.in_project(pr).this_week.sum_duration,
            week_target: pr.sum_target
          }
        end
          .reject { |hash| hash[:week_total] == 0 && hash[:week_target] == 0 }
          .sort_by { |hash| -hash[:week_total] }
      }
    end
  end
end
