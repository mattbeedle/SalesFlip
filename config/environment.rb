# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Salesflip::Application.initialize!

Salesflip::Application.configure do
  begin
    db_config = YAML::load(File.read("#{Rails.root}/config/mongoid.yml"))[Rails.env]
    config.middleware.use Rack::GridFS, :hostname => db_config['host'],
      :port => db_config['port'], :database => db_config['database'], :prefix => 'uploads',
      :user => db_config['user'], :password => db_config['password']
  rescue IOError
    raise IOError, 'config/mongodb.yml could not be loaded'
  rescue StandardError => e
    raise StandardError, "Error: #{e} occurred"
  end
end