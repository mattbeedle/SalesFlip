module DataMapper
  # Tracks the names of changed model attributes, useful for generating actions
  # based on changes in after save/update hooks.
  module Changes
    extend ActiveSupport::Concern

    Model.append_inclusions self

    included do
      before :attribute_set do |property,_|
        changed << property.to_s
      end

      after :save do |*args|
        changed.clear if clean?
      end
    end

    def changed
      @changed ||= Set.new
    end

  end
end
