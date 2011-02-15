set :branch, "master"

role :app, "78.47.219.204", :primary => true
role :app, "78.47.219.204"

namespace :deploy do
  task :restart, :roles => :app do
    run("kill -USR2 `cat /tmp/unicorn.pid`")
    run("/etc/init.d/delayed_job restart")
  end
end
