Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    {
      pid: Process.pid,
      ip: event.payload[:ip],
      user: event.payload[:user],
      time: event.time.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
      params: event.payload[:params].except(*%w(controller action format id))
    }
  end
  config.lograge.formatter = ->(data) {
    "#{data[:time]} pid=#{data[:pid]} method=#{data[:method]} path=#{data[:path]} controller=#{data[:controller]}##{data[:action]} params=#{data[:params]} status=#{data[:status]} duration=#{data[:duration]}ms ip=#{data[:ip]} user=#{data[:user]}"
  }
end
