rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 6
preload_app true
timeout 30
listen '/data/salesflip/current/tmp/sockets/unicorn.sock', :backlog => 2048
