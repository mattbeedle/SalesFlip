source :gemcutter

gem 'rails'

gem 'sqlite3-ruby',         :require => 'sqlite3'

gem "bson_ext"
gem "mongo"

gem 'haml'
gem 'inherited_resources'
gem 'warden'
gem 'devise'

gem 'dm-core', :git => 'git://github.com/bernerdschaefer/dm-core.git'
gem 'dm-devise'
gem 'dm-migrations', :git => 'git://github.com/datamapper/dm-migrations.git'
gem 'dm-postgres-adapter'
gem 'dm-rails'
gem 'dm-timestamps'
gem 'dm-transactions'
gem 'dm-types', :git => 'git://github.com/datamapper/dm-types.git'
gem 'dm-validations', :git => 'git://github.com/datamapper/dm-validations.git'

gem 'delayed_job'
gem 'delayed_job_data_mapper', '1.0.0.rc'
gem 'compass'
gem 'uuid'
gem 'has_scope'
gem 'navvy'
gem 'aaronh-chronic',       :git => 'git://github.com/AaronH/chronic.git', :require => 'chronic'
gem 'mail'
gem 'beanstalk-client'
gem 'will_paginate',        '3.0.pre'
gem 'riddle'
gem 'carrierwave',          :git => 'git://github.com/jnicklas/carrierwave.git'
gem 'memcached'
# gem 'mongo_session_store',  :git => 'git://github.com/mattbeedle/mongo_session_store.git'
gem 'simple_form'
gem 'has_constant',         :git => 'git://github.com/mattbeedle/has_constant.git'
gem 'hassle',               :git => 'git://github.com/koppen/hassle.git'
gem 'sunspot',              :require => 'sunspot'
gem 'sunspot_rails'
gem 'remail'
# gem 'rack-gridfs',          :require => 'rack/gridfs', :git => 'git://github.com/mattbeedle/rack-gridfs.git'
gem 'amatch'
gem 'gravtastic'
gem 'cancan'
gem 'unicorn'

# Plugins
gem 'salesflip-lead_notifications', :require => 'lead_notifications'

group :production do
  gem 'smurf'
  gem 'mbeedle-heroku-autoscale', :require => 'heroku/autoscale'
  gem 'mysql2'
  gem 'newrelic_rpm'
end

group :development do
  gem 'ruby-debug19'
  gem 'wirble'
  gem 'heroku',     :require => nil
  gem 'thin',       :require => nil
  gem 'capistrano', :require => nil
end

group :test do
  gem 'pickle'
  gem 'capybara'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'spork'
  gem 'launchy'
  # gem 'autotest-rails',   :require => 'autotest/rails'
  gem 'fakeweb'
  gem 'machinist'
  gem 'mocha'
  gem 'faker', '0.3.1'
  gem 'shoulda'
  gem 'database_cleaner'
  # gem 'mbeedle-heroku-autoscale', :require => 'heroku/autoscale'
  gem 'timecop'
  gem 'test_notifier'
end
