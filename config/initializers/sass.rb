Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets/compiled' }

Salesflip::Application.configure do
  config.middleware.insert_before "ActionDispatch::Static", Sass::Plugin::Rack
end
