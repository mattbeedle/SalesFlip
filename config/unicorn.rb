rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 8
working_directory '/data/salesflip/current'
preload_app true
timeout 30
listen '/tmp/salesflip.sock', :backlog => 2048

before_fork do |server, worker|
  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
