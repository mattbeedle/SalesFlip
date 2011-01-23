set :use_sudo, false

set :git_shallow_clone, 1
set :keep_releases, 5
set :application, "salesflip"
set :user, "root"
set :deploy_to, "/data/salesflip"
set :runner, "root"
set :repository,  "git@careerme.unfuddle.com:careerme/salesflip.git"
set :scm, :git

ssh_options[:paranoid] = false
default_run_options[:pty] = true

role :app, "salesflip.com", :primary => true
role :web, "salesflip.com"

before 'deploy:restart', 'deploy:bundle'
after 'deploy:restart', 'deploy:symlinks'

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  task :restart, :roles => :app do
    run "/etc/init.d/unicorn/restart"
  end

  task :symlinks, :roles => :app do
    run "ln -s #{shared_path}/solr #{current_path}/solr"
  end

  task :bundle, :roles => :app do
    run "cd #{release_path} && bundle install --without development test"
  end

  task :delayed_job, :roles => :app do
    run "cd #{release_path} && ./script/delayed_job restart"
  end
end
