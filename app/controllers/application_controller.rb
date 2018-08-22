class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    work_entries_path
  end

  # See https://github.com/plataformatec/devise#strong-parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:time_zone])
  end

  # Add request metadata to Lograge log payload
  def append_info_to_payload(payload)
    super
    payload[:ip] = request.remote_ip
    payload[:user] = current_user&.id || "none"
  end

  # Prevent timeouts from causing the app to freak out
  rescue_from ActionController::InvalidAuthenticityToken do |e|
    logger.error "A user just got ActionController::InvalidAuthenticityToken #{e} on request #{request.method} #{request.original_url}. Redirecting to the login page."
    redirect_to new_user_session_path, alert: "Whoops, it looks like your session timed out. Please log in and try again."
  end
end
