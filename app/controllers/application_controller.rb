class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    work_entries_path
  end

  # Prevent timeouts from causing the app to freak out, that's just unprofessional
  rescue_from ActionController::InvalidAuthenticityToken do |e|
    logger.error "A user just got ActionController::InvalidAuthenticityToken #{e} on request #{request.method} #{request.original_url}. Redirecting to the login page."
    redirect_to new_user_session_path, alert: "Whoops, it looks like your session timed out. Please log in and try again."
  end
end
