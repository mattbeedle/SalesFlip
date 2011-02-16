Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets/compiled' }

Salesflip::Application.configure do
  env = Rails.env
  if env.development? || env.test?
    config.middleware.insert_before "ActionDispatch::Static", Sass::Plugin::Rack
  else
    config.middleware.insert_before "Rack::Lock", Sass::Plugin::Rack
  end
end
