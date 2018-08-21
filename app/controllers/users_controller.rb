class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    current_user.update!(update_params)
    respond_to do |format|
      format.html { redirect_to user_path(current_user.id), notice: "Your settings have been updated." }
      format.json { render json: {success: true} }
    end
  end

  private

  def update_params
    params.require(:user).permit(:time_zone)
  end
end
