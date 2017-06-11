class HomeController < ApplicationController
  def home
  end

  def about
  end

  def keepalive
    render json: { success: true }
  end

  def error
    raise "A test error!"
  end

  def login_as
    unless current_user and current_user.id.to_s.in?(ENV.fetch("ADMIN_USER_IDS").split(","))
      raise "Unauthorized user #{current_user.try(:id).inspect} tried to login as user_id #{params[:user_id].inspect}!"
    end
    @user = User.find(params[:user_id])
    sign_in @user
    redirect_to root_path, notice: "You're now signed in as #{@user.email}."
  end
end
