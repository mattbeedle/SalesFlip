module ActionController
  module Caching
    class Sweeper
      include Singleton
      include DataMapper::Observer

      attr_accessor :controller

      def before(controller)
        self.controller = controller
        callback(:before) if controller.perform_caching
        true # before method from sweeper should always return true
      end

      def after(controller)
        callback(:after) if controller.perform_caching
        # Clean up, so that the controller can be collected after this request
        self.controller = nil
      end

      protected
        # gets the action cache path for the given options.
        def action_path_for(options)
          Actions::ActionCachePath.new(controller, options).path
        end

        # Retrieve instance variables set in the controller.
        def assigns(key)
          controller.instance_variable_get("@#{key}")
        end

      private
        def callback(timing)
          controller_callback_method_name = "#{timing}_#{controller.controller_name.underscore}"
          action_callback_method_name     = "#{controller_callback_method_name}_#{controller.action_name}"

          __send__(controller_callback_method_name) if respond_to?(controller_callback_method_name, true)
          __send__(action_callback_method_name)     if respond_to?(action_callback_method_name, true)
        end

        def method_missing(method, *arguments, &block)
          return if @controller.nil?
          @controller.__send__(method, *arguments, &block)
        end
    end
  end
end
