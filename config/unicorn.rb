rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 8
working_directory '/data/salesflip/current'
preload_app true
timeout 30
listen '/data/salesflip/current/tmp/sockets/unicorn.sock', :backlog => 2048
