set :deploy_to, "/data/salesflip-staging"
set :branch, "dm-head-fixes"

namespace :deploy do
  task :restart, :roles => :app do
    run "/etc/init.d/unicorn-staging restart"
  end
end
