Salesflip::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  I18n.default_locale = :de

  config.active_support.deprecation = :log

  config.middleware.use Rack::GridFS, :hostname => ENV['MONGODB_HOST'],
    :port => ENV['MONGODB_PORT'], :database => 'salesflip',
    :prefix => 'uploads', :user => ENV['MONGODB_USER'],
    :password => ENV['MONGODB_PASSWORD']

  config.after_initialize do
    require 'sunspot/rails'
    Sunspot.config.solr.url = ENV['WEBSOLR_URL']
  end

  # require 'heroku/autoscale'
  # config.middleware.use Heroku::Autoscale,
    # :username  => ENV["HEROKU_USERNAME"],
    # :password  => ENV["HEROKU_PASSWORD"],
    # :app_name  => ENV["HEROKU_APP_NAME"],
    # :min_dynos => 1,
    # :max_dynos => 20,
    # :queue_wait_low  => 100,  # milliseconds
    # :queue_wait_high => 2000, # milliseconds
    # :min_frequency   => 60    # seconds

  config.action_mailer.delivery_method = :remail
  config.action_mailer.remail_settings = {
    :app_id  => 'salesflip',
    :api_key => '20015510-959d-012d-a4ae-001c25a0b06f'
  }

  config.external_user_update_url = "http://app.1000jobboersen.de/external_updates/user"
  config.external_offer_request_url = "http://app.1000jobboersen.de/external_updates/create_offer_request"
  config.external_offer_rework_url = "http://app.1000jobboersen.de/external_updates/rework_offer_request"
end
