require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

require "dm-core"

DataMapper::Property::String.length(255)
DataMapper::Property::Text.length(65535)

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Salesflip
  class Application < Rails::Application
    I18n.load_path += Dir[Rails.root + 'config/locales/*.{rb,yml}']

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W( #{config.root}/lib #{config.root}/app/sweepers )

    require 'cancan/ext/inherited_resource'

    require 'data_mapper/postgres'

    require 'data_mapper/any_of'
    require 'data_mapper/changes'
    require 'data_mapper/collection_extensions'
    require 'data_mapper/multiparameter_attribute_support'
    require 'data_mapper/polymorphic'
    require 'data_mapper/scope'
    require 'data_mapper/sweeper'
    require 'data_mapper/validations'
    require 'data_mapper/will_paginate'
    require 'data_mapper/yaml'

    require 'rails/partials'

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.action_mailer.default_url_options = { :host => 'salesflip.com' }

    config.after_initialize do
      I18n.locale = I18n.default_locale
      DataMapper.auto_upgrade!
    end

    # This is set here for dev environments.
    config.external_user_update_url = "http://localhost:8080/external_updates/user"
    config.external_offer_request_url = "http://localhost:8080/external_updates/create_offer_request"
    config.external_offer_rework_url = "http://localhost:8080/external_updates/rework_offer_request"

    # The access key should be stored in the environment on the servers so the
    # information being sent can be encrypted.
    config.external_access_key = ENV["HR_NEW_MEDIA_ACCESS_KEY"]

    Encryptor.default_options.merge!(key: config.external_access_key)
  end
end
