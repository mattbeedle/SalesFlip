 begin
  db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongoid.yml")))
rescue
  raise IOError, 'config/mongoid.yml could not be loaded'
end

CarrierWave.configure do |config|
  config.storage              = :grid_fs
  config.grid_fs_database     = db_config[Rails.env]['database']
  config.grid_fs_access_url   = '/uploads'
  config.grid_fs_host         = db_config[Rails.env]['host']
  config.grid_fs_port         = db_config[Rails.env]['port']
  if Rails.env.staging?
    config.grid_fs_username     = ENV['MONGODB_STAGING_USER']
    config.grid_fs_password     = ENV['MONGODB_STAGING_PASSWORD']
  elsif Rails.env.production?
    config.grid_fs_username     = ENV['MONGODB_USER']
    config.grid_fs_password     = ENV['MONGODB_PASSWORD']
  end
end
