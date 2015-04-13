class ClientsController < ApplicationController
  before_action :load_client, only: [:edit, :update, :show]

  def index
    @clients = current_user.clients
  end

  def new
    @client = current_user.clients.new
  end

  def create
    @client = current_user.clients.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "Client created successfully."
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @client.update_attributes(client_params)
      redirect_to clients_path, notice: "Client updated successfully."
    else
      render 'edit'
    end
  end

  def show
  end

private

  def client_params
    params.require(:client).permit(:name)
  end

  def load_client
    @client = current_user.clients.find(params[:id])
  end
end
