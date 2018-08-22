if defined?(Rack::Timeout)
  # Disable logs, they're verbose and redundant
  Rack::Timeout::Logger.disable
end
