class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_invoice, only: [:show, :update, :destroy]

  def index
    @invoices = current_user.invoices.order("date_end DESC").
                paginate(page: params[:page], per_page: 50)
  end

  def new
    @invoice = current_user.invoices.new(date_end: Date.current)
  end

  def preview
    @project = current_user.projects.find(params[:project_id])

    entries_in_project = current_user.work_entries.in_project(@project)
    entries_in_date_range = entries_in_project
      .starting_date(params[:date_start])
      .ending_date(params[:date_end])

    @billable         = entries_in_date_range.uninvoiced.billable.order(:date)
    @unbillable       = entries_in_date_range.uninvoiced.unbillable.order(:date)
    @already_invoiced = entries_in_date_range.invoiced.order(:date)
    @orphaned         = entries_in_project.uninvoiced.billable.
                        where("date < ?", params[:date_start]).order(:date)

    render partial: "preview"
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)
    included_entries = @invoice.eligible_entries
    total_hours = included_entries.pluck(:duration).sum
    total_bill = Money.new(included_entries.map(&:bill).sum)
    @invoice.total_hours = total_hours
    @invoice.total_bill = total_bill

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
    @invoice.destroy!
    redirect_to invoices_path, notice: "Invoice deleted successfully."
  end

  def download
    send_data CsvGenerator.invoices_csv(current_user),
      filename: "invoices_#{Time.now.to_s(:db)}.csv",
      type: "text/csv"
  end

private

  def load_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:project_id, :date_start, :date_end, :is_sent, :is_paid)
  end

end
