 begin
  db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongoid.yml")))
rescue
  raise IOError, 'config/mongoid.yml could not be loaded'
end

CarrierWave.configure do |config|
  config.storage              = :grid_fs
  config.grid_fs_access_url   = '/uploads'
  if Rails.env.staging?
    config.grid_fs_database     = 'salesflip_staging'
    config.grid_fs_host         = ENV['MONGODB_STAGING_HOST']
    config.grid_fs_username     = ENV['MONGODB_STAGING_USER']
    config.grid_fs_password     = ENV['MONGODB_STAGING_PASSWORD']
    config.grid_fs_port         = 27017
  elsif Rails.env.production?
    config.grid_fs_database     = 'salesflip'
    config.grid_fs_host         = ENV['MONGODB_HOST']
    config.grid_fs_username     = ENV['MONGODB_USER']
    config.grid_fs_password     = ENV['MONGODB_PASSWORD']
    config.grid_fs_port         = 27017
  else
    config.grid_fs_database     = 'salesflip_development'
    config.grid_fs_host         = 'localhost'
    config.grid_fs_port         = 27017
  end
end
