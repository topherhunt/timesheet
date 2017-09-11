class WorkEntriesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :destroy, :stop, :show]
  before_action :prepare_filter, only: :index

  def index
    @entries = current_user.work_entries
      .order_naturally
      .includes(:project, :invoice)
    filter_entries
    @totals = calculate_totals
    # Pagination must wait until after totals are calculated
    @entries = @entries.paginate(page: params[:page], per_page: 50)
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

  def prepare_filter
    @filters = {}

    if params[:filter]
      @filters = params
      cookies[:filter] = { value: @filters.to_json, expires: 1.hour.from_now }
    elsif params[:clear_filter]
      cookies.delete :filter
    elsif cookies[:filter]
      @filters = JSON.parse(cookies[:filter]).symbolize_keys
    end
  end

  def filter_entries
    # TODO: This doesn't belong here. Move to a new WorkEntriesFilter class
    return unless @filters.any?

    if @filters[:project_id].present?
      @project = current_user.projects.find(@filters[:project_id])
      @entries = @entries.in_project(@project)
    end

    if @filters[:date_start].present?
      @entries = @entries.starting_date(@filters[:date_start])
    end

    if @filters[:date_end].present?
      @entries = @entries.ending_date(@filters[:date_end])
    end

    if @filters[:status].present?
      if @filters[:status] == "unbillable"
        @entries = @entries.unbillable
      # TODO: other status filter options
      else
        raise "Unknown status filter '#{@filters[:status]}'!"
      end
    end

    if @filters[:duration_min].present?
      @entries = @entries.where('duration >= ?', @filters[:duration_min])
    end

    if @filters[:duration_max].present?
      @entries = @entries.where('duration <= ?', @filters[:duration_max])
    end

    if @filters[:memo_contains].present?
      snippet = "%#{@filters[:memo_contains]}%"
      @entries = @entries.where("goal_notes LIKE ? OR invoice_notes LIKE ? OR admin_notes LIKE ?", snippet, snippet, snippet)
    end
  end

  def calculate_totals
    if @filters.any?
      {
        total: @entries.total_duration,
        billable: @entries.billable.total_duration
      }
    else
      {
        day: {
          all: {
            total: @entries.today.total_duration,
            billable: @entries.today.billable.total_duration
          },
          projects: top_level_project_totals_today
        },
        week: {
          all: {
            total: @entries.this_week.total_duration,
            billable: @entries.this_week.billable.total_duration
          },
          projects: top_level_project_totals_this_week
        },
        targets: {
          projects: project_totals_and_targets_this_week
        }
      }
    end
  end

  def top_level_project_totals_today
    current_user.projects.roots.map do |project|
      entries = WorkEntry.where(project_id: project.self_and_descendant_ids).today
      {
        project_name: project.name_with_ancestry,
        total: entries.total_duration,
        billable: entries.billable.total_duration
      }
    end
      .select { |hash| hash[:total] > 0 }
      .sort_by { |hash| -hash[:total] }
  end

  def top_level_project_totals_this_week
    current_user.projects.roots.map do |project|
      entries = WorkEntry.where(project_id: project.self_and_descendant_ids).this_week
      {
        project_name: project.name_with_ancestry,
        total: entries.total_duration,
        billable: entries.billable.total_duration
      }
    end
      .select { |hash| hash[:total] > 0 }
      .sort_by { |hash| -hash[:total] }
  end

  def project_totals_and_targets_this_week
    current_user.projects.where("min_hours_per_week > 0")
      .order("min_hours_per_week DESC")
      .map do |project|
        entries = WorkEntry.where(project_id: project.self_and_descendant_ids).this_week
        {
          project_name: project.name_with_ancestry,
          expected: project.min_hours_per_week,
          actual: entries.total_duration
        }
      end
  end

  def warn_if_old_unbilled_entries
    current_user.projects.where(requires_daily_billing: true).each do |project|
      if current_user.work_entries.in_project(project).billable.unbilled.old.any?
        flash.now.alert = "You have old unbilled work entries for #{project.name}."
        return
      end
    end
  end

end
