set :deploy_to, "/data/salesflip-staging"
set :runner, "root"
set :branch, "dn-for-speed"

namespace :deploy do
  task :restart, :roles => :app do
    run "/etc/init.d/unicorn-staging restart"
  end
end
