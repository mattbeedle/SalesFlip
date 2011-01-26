set :deploy_to, "/data/salesflip"
set :branch, "master"

role :app, "46.4.64.83", :primary => true
role :web, "46.4.64.83"

set :user, "root"
set :runner, "root"

namespace :deploy do
  task :restart, :roles => :app do
    # run "/etc/init.d/unicorn restart"
  end
end
