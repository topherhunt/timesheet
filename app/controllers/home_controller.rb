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
end
