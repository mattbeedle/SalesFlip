set :application, "salesflip"
set :repository,  "git://github.com/mattbeedle/SalesFlip.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, ENV['SALESFLIP_WEB_SERVER']                          # Your HTTP server, Apache/etc
role :app, ENV['SALESFLIP_WEB_SERVER']                          # This may be the same as your `Web` server

set :user, ENV['SALESFLIP_USER']
set :password, ENV['SALESFLIP_PASSWORD']
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

default_run_options[:pty] = true

# Set branch to current
set :branch, `git branch`.lines.to_a.find {|b| b =~ /\*/ }.sub(/\*\s/, '').chomp

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

before 'deploy:restart', 'deploy:bundle'
after 'deploy:bundle', 'deploy:delayed_job'
after 'deploy:restart', 'deploy:symlinks'
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
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
