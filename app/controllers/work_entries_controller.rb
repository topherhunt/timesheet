class WorkEntriesController < ApplicationController
  include DateHelper

  before_action :authenticate_user!
  before_action :load_entry, only: [:edit, :update, :stop, :destroy, :stop, :show]

  def index
    @entries = current_user.work_entries
    @filters = prepare_filters

    if @filters.any?
      @entries = WorkEntriesFilter.new(current_user, @entries, @filters).run
      @filter_totals = calculate_filter_totals
    else
      @totals_per_project = TotalsPerProjectCalculator.new(user: current_user).run
      @value_created = calculate_value_created
    end

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
    @entry = current_user.work_entries.create!(
      create_params.merge(started_at: Time.current)
    )
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
      respond_to do |format|
        format.html { redirect_to work_entries_path }
        format.json { render json: {success: true} }
      end
    else
      respond_to do |format|
        format.html { render 'edit' }
        format.json { render json: {errors: @entry.errors.full_messages} }
      end
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
        status: e.exclude_from_invoice ? "unbillable" : "billable",
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

    confirmation =

    respond_to do |format|
      format.html {
        redirect_to work_entries_path,
          notice: "Merged entries #{@from.id} & #{@to.id}."
      }
      format.json {
        render json: {
          success: true,
          new_duration: @to.duration.round(1),
          new_invoice_notes: @to.invoice_notes
        }
      }
    end
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
    p = params.require(:work_entry).permit(
      :project_id,
      :duration,
      :invoice_notes,
      :admin_notes,
      :exclude_from_invoice,
      :creates_value
    )
    if started_at_from_params.present?
      p[:started_at] = started_at_from_params
    end
    p
  end

  # TODO: Display human-friendly error message if date/time can't be parsed.
  # Currently if there's a parsing error it will 500 the whole page.
  # It would be nicer to render the edit page with error messages.
  # That might look like:
  # - method WorkEntry#parse_started_at(date_input, time_input): parses date&time
  #   and assigns started_at if valid, otherwise adds error
  # - Controller #update would `assign_attributes` for most params, then call
  #   `@entry.parse_started_at`, then `#save` to persist if valid.
  def started_at_from_params
    p = params[:work_entry]
    if p[:started_at_date].present?
      date = parse_date(p[:started_at_date])
      time_duration = parse_time(p[:started_at_time])
      date + time_duration
    end
  end

  def parse_date(input)
    date = Time.zone.parse(input)
    raise("Don't know how to parse #{input.inspect} into a date!") if date.nil?
    date
  end

  # TODO: Write my own time parser. This one behaves erratically in edge cases,
  # e.g. "12:01 a" => 7:01 am !?
  def parse_time(input)
    time = Time.zone.parse(input)
    if time.nil? || (time - time.beginning_of_day == 0 && !input.include?("12"))
      raise("Don't know how to parse #{input.inspect} into a time!")
    end
    (time - time.beginning_of_day)
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

  def calculate_filter_totals
    {
      total: @entries.sum_duration,
      billable: @entries.not_excluded.sum_duration
    }
  end

  def calculate_value_created
    {
      today: @entries.today.where(creates_value: true).sum_duration * 50,
      week: @entries.this_week.where(creates_value: true).sum_duration * 50
    }
  end
end
