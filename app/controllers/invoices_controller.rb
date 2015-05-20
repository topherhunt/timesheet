class InvoicesController < ApplicationController
  before_action :authenticate_user!

  before_action :load_invoice, only: [:show, :update, :destroy]

  def index
    @invoices = current_user.invoices.order("date_start DESC").
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

    @billable         = entries_in_date_range.uninvoiced.billable
    @unbillable       = entries_in_date_range.uninvoiced.unbillable
    @already_invoiced = entries_in_date_range.invoiced
    @orphaned         = entries_for_client.uninvoiced.
                        where("date < ?", params[:date_start])

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
    @invoice.work_entries.update_all(invoice_id: nil)
    @invoice.destroy!

    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

private

  def load_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:client_id, :date_start, :date_end, :is_sent, :is_paid)
  end

end
