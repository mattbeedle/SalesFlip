require 'carrierwave/orm/mongoid'

begin
  db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongoid.yml")))
rescue
  raise IOError, 'config/mongoid.yml could not be loaded'
end

CarrierWave.configure do |config|
  config.storage              = :grid_fs
  config.grid_fs_database     = Mongoid.config.database.name
  config.grid_fs_access_url   = '/uploads'
  config.grid_fs_host         = Mongoid.config.database.connection.host_to_try.first
  config.grid_fs_port         = Mongoid.config.database.connection.host_to_try.last
  unless Mongoid.config.database.connection.auths.blank?
    config.grid_fs_username     = Mongoid.config.database.connection.auths['username']
    config.grid_fs_password     = Mongoid.config.database.connection.auths['password']
  end
end
