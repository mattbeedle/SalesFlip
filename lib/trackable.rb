module Trackable
  extend ActiveSupport::Concern

  included do
    singular_name = name.downcase
    through_relationship_name = :"#{singular_name}_trackers"

    through_model = DataMapper::Model.new

    Object.const_set("#{name}Tracker", through_model)

    through_model.belongs_to :tracker, User, :key => true
    through_model.belongs_to :"#{singular_name}", :key => true

    has n, through_relationship_name
    has n, :trackers, User,
      through: through_relationship_name
  end

  module ClassMethods
    def tracked_by(user)
      all(trackers.id => user.id)
    end
  end

  def tracker_ids
    trackers.map &:id
  end

  def tracked_by?(user)
    trackers && trackers.include?(user)
  end

  def tracker_ids=(ids)
    self.trackers = User.all(:id => ids)
  end

  def remove_tracker_ids=(ids)
    olds_ids = attribute_get(:tracker_ids) || []
    attribute_set :tracker_ids, olds_ids.map(&:to_s) - ids.map(&:to_s)
  end
end
