module Trackable
  extend ActiveSupport::Concern

  included do
    has n, :trackers, User, through: ::DataMapper::Resource
  end

  module ClassMethods
    def tracked_by(user)
      all(trackers: { id: user.id })
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
