set :deploy_to, "/data/salesflip"
set :branch, "master"

role :app, "46.4.64.83", :primary => true
role :web, "46.4.64.83"

set :user, "root"
set :runner, "root"

namespace :deploy do
  task :restart, :roles => :app do
    pid = File.read("/tmp/unicorn.pid").to_i
    run("kill -USR2 #{pid}")
  end
end
