set :stages, %w(production staging)
set :default_stage, "staging"

require "capistrano/ext/multistage"

set :use_sudo, false

set :deploy_to, "/data/salesflip"
set :git_shallow_clone, 1
set :keep_releases, 5
set :user, "root"
set :runner, "root"
set :repository,  "git@careerme.unfuddle.com:careerme/salesflip.git"
set :scm, :git

ssh_options[:paranoid] = false
default_run_options[:pty] = true

before 'deploy:restart', 'deploy:bundle'
after 'deploy:bundle', 'deploy:delayed_job'
after 'deploy:restart', 'deploy:symlinks'

namespace :deploy do
  task :start, :roles => :app do
    run "/etc/init.d/unicorn start"
    run "/etc/init.d/delayed_job start"
    run "/etc/init.d/solr start"
  end

  task :stop, :roles => :app do
    run "/etc/init.d/unicorn stop"
    run "/etc/init.d/delayed_job stop"
    run "/etc/init.d/solr stop"
  end

  task :restart, :roles => :app do
    run "kill -USR2 `cat /tmp/unicorn.pid`"
    run "/etc/init.d/delayed_job restart"
  end

  task :symlinks, :roles => :app do
    run "ln -s #{shared_path}/solr #{current_path}/solr"
  end

  task :bundle, :roles => :app do
    run "cd #{current_path} && bundle install --without development test"
  end
end
