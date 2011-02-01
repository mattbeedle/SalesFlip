rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 8
working_directory '/data/salesflip/current'
preload_app true
timeout 30
listen '/tmp/salesflip.sock', :backlog => 2048
pid "/tmp/unicorn.pid"

before_fork do |server, worker|
  old_pid = "/tmp/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  DataObjects::Pooling.pools.each do { |pool| pool.dispose }
end
