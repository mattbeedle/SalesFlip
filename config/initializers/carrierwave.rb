require 'carrierwave/orm/mongoid'

begin
  db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongoid.yml")))
rescue
  raise IOError, 'config/mongoid.yml could not be loaded'
end

CarrierWave.configure do |config|
  config.storage              = :grid_fs
  config.grid_fs_database     = Mongoid.database.name
  config.grid_fs_access_url   = '/uploads'
  config.grid_fs_host         = Mongoid.config.connection.host
  config.grid_fs_port         = Mongoid.config.connection.port
  config.grid_fs_username     = Mongoid.config.connection.auths[0]['username']
  config.grid_fs_password     = Mongoid.config.connection.auths[0]['password']
end
