set :deploy_to, "/data/salesflip"
set :branch, "master"

namespace :deploy do
  task :restart, :roles => :app do
    run "/etc/init.d/unicorn restart"
  end
end
