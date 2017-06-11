# Copied from https://devcenter.heroku.com/articles/rails-unicorn

worker_processes ENV['UNICORN_WORKERS'].to_i
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap('TERM') do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead."
    Process.kill 'QUIT, Process.id'
  end

  ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap('TERM') do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT."
  end

  ActiveRecord::Base.establish_connection
end
