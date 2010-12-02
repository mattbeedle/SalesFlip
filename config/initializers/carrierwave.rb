require 'carrierwave/orm/mongoid'

begin
  db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongoid.yml")))
rescue
  raise IOError, 'config/mongoid.yml could not be loaded'
end

# TODO: since gem updating Mongoid.config.master.connection.host and port don't work
CarrierWave.configure do |config|
  config.storage              = :grid_fs
  config.grid_fs_database     = Mongoid.database.name
  config.grid_fs_access_url   = '/uploads'
  config.grid_fs_host         = Mongoid.config.master.connection.nodes.first.first
  config.grid_fs_port         = Mongoid.config.master.connection.nodes.first.last
  config.grid_fs_username     = Mongoid.config.master.connection.auths[0].try(:"['username']")
  config.grid_fs_password     = Mongoid.config.master.connection.auths[0].try(:"['password']")
end