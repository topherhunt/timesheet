class WorkEntriesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :destroy, :stop, :show]

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
    warn_if_old_unbilled_entries
  end

  def show
    redirect_to edit_work_entry_path(@entry)
  end

  def create
    @entry = current_user.work_entries.new(entry_params)
    @entry.date ||= Date.current

    project = current_user.projects.find(params[:work_entry][:project_id])
    @entry.will_bill = (project.inherited_rate > 0)

    if @entry.save
      if params[:commit] == "Edit"
        redirect_to edit_work_entry_path(@entry)
      else
        redirect_to work_entries_path
      end
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @entry.stop! if params[:stop_timer]

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

  def prior_entry
    load_entry
    if e = @entry.prior_entry
      render json: {
        entry_id: e.id,
        billing_status_term: e.billing_status_term,
        project_name: e.project.name,
        date: date(e.date, weekday: true),
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

  def entry_params
    params.require(:work_entry).permit(:project_id, :date, :duration, :will_bill, :is_billed, :goal_notes, :invoice_notes, :admin_notes)
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
        all: {
          today_total: @entries.today.sum_duration,
          week_total: @entries.this_week.sum_duration,
          week_billable: @entries.this_week.billable.sum_duration
        },
        projects: current_user.projects.roots.map do |pr|
          {
            name: pr.name,
            today_total: @entries.in_project(pr).today.sum_duration,
            week_total: @entries.in_project(pr).this_week.sum_duration,
            week_billable: @entries.in_project(pr).this_week.billable.sum_duration,
            week_target: pr.sum_target
          }
        end
          .reject { |hash| hash[:week_total] == 0 && hash[:week_target] == 0 }
          .sort_by { |hash| -hash[:week_total] }
      }
    end
  end

  # TODO: I think maybe I don't need this anymore.
  def warn_if_old_unbilled_entries
    current_user.projects.where(requires_daily_billing: true).each do |project|
      if current_user.work_entries.in_project(project).billable.unbilled.old.any?
        flash.now.alert = "You have old unbilled work entries for #{project.name}."
        return
      end
    end
  end

end
