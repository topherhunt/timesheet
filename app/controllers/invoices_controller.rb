class InvoicesController < ApplicationController
  before_action :authenticate_user!

  before_action :load_invoice, only: [:show, :update, :destroy]
  before_action :ensure_timer_not_running, only: [:new]

  def index
    @invoices = current_user.invoices.order("date_end DESC").
                paginate(page: params[:page], per_page: 50)
  end

  def new
    @invoice = current_user.invoices.new(date_end: Date.current)
    @clients = current_user.clients.where("rate_cents IS NOT NULL").order(:name)
  end

  def preview
    @client = current_user.clients.find(params[:client_id])

    entries_for_client = current_user.work_entries.for_client(@client)
    entries_in_date_range = entries_for_client.
      starting_date(params[:date_start]).
      ending_date(params[:date_end])

    @billable         = entries_in_date_range.uninvoiced.billable.order(:date)
    @unbillable       = entries_in_date_range.uninvoiced.unbillable.order(:date)
    @already_invoiced = entries_in_date_range.invoiced.order(:date)
    @orphaned         = entries_for_client.uninvoiced.billable.
                        where("date < ?", params[:date_start]).order(:date)

    render partial: "preview"
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)
    @invoice.rate = @invoice.client.rate

    included_entries = @invoice.eligible_entries
    @invoice.total_hours = included_entries.pluck(:duration).sum

    if @invoice.save
      included_entries.update_all(invoice_id: @invoice.id)
      redirect_to invoices_path, notice: "Invoice created."
    else
      redirect_to new_invoice_path, alert: "Your invoice was NOT saved: #{@invoice.errors.full_messages}"
    end
  end

  def show
    @title = "Invoice #{@invoice.id} - #{@invoice.client.name} - #{@invoice.date_end}"
    render "show", layout: false
  end

  def update
    if @invoice.update_attributes(invoice_params)
      redirect_to invoices_path, notice: "Invoice updated."
    else
      redirect_to invoices_path, alert: "Update FAILED: #{@invoice.errors.full_messages}"
    end
  end

  def destroy
    @invoice.destroy!
    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

  def download
    send_data invoices_csv,
      filename: "invoices_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
  end

private

  def load_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:client_id, :date_start, :date_end, :is_sent, :is_paid)
  end

  def invoices_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [
        :id,
        :client,
        :rate,
        :date_start,
        :date_end,
        :total_hours,
        :num_work_entries,
        :is_sent,
        :is_paid,
        :created_at,
        :updated_at
      ]

      current_user.invoices.order(:created_at).each do |i|
        csv << [
          i.id,
          i.client.name,
          i.rate.format,
          i.date_start,
          i.date_end,
          i.total_hours,
          i.work_entries.count,
          i.is_sent,
          i.is_paid,
          i.created_at,
          i.updated_at
        ]
      end
    end
  end

  def ensure_timer_not_running
    if current_user.work_entries.running.any?
      redirect_to work_entries_path, alert: "You have a timer running; stop it before creating invoices."
    end
  end

end
