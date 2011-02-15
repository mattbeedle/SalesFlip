require ::File.expand_path("../config/environment",  __FILE__)
require "resque/server"

RESQUE_PASSWORD = ENV["RESQUE_PASSWORD"]
if RESQUE_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == RESQUE_PASSWORD
  end
end

run Rack::URLMap.new \
  "/"       => Salesflip::Application,
  "/resque" => Resque::Server.new
