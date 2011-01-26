set :deploy_to, "/data/salesflip"
set :branch, "master"

role :app, "46.4.64.83", :primary => true
role :web, "46.4.64.83"

namespace :deploy do
  task :start do ; end
  task :stop do; end
  task :restart, :roles => :app do
    # run "/etc/init.d/unicorn restart"
  end
end
