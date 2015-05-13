class HomeController < ApplicationController
  def home
  end

  def about
  end

  def keepalive
    render json: { success: true }
  end
end
