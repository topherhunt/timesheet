class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @metrics = current_user.metrics.order(:label)
  end

  def new
    @metric = current_user.metrics.new
  end

  def create
    @metric = current_user.metrics.new(metric_params)
    if @metric.save
      redirect_to metrics_path, notice: "Metric created."
    else
      render "new"
    end
  end

  def edit
    @metric = current_user.metrics.find(params[:id])
  end

  def update
    @metric = current_user.metrics.find(params[:id])
    if @metric.update(metric_params)
      # TODO: bust cache?
      redirect_to metrics_path, notice: "Metric updated."
    else
      render "edit"
    end
  end

  def destroy
    @metric = current_user.metrics.find(params[:id])
    @metric.destroy!
    redirect_to metrics_path, notice: "Metric deleted."
  end

  private

  def metric_params
    h = params.require(:metric).permit(
      :label,
      :date_filter_type,
      :date_filter_since_custom_date,
      :operation_type
    ).merge(
      project_ids: params[:metric][:project_ids].join(","),
      statuses: params[:metric][:statuses].join(",")
    )
  end
end
