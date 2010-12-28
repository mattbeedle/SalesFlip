module ParanoidDelete
  extend ActiveSupport::Concern
  
  included do
    property :deleted_at, DataMapper::Property::ParanoidDateTime

    alias_method_chain :destroy, :paranoid
    before :save, :recently_restored?
  end

  module ClassMethods
    def not_deleted
      all(:deleted_at => nil)
    end

    def deleted
      all(:deleted_at.not => nil)
    end
  end

  def destroy_with_paranoid
    @recently_destroyed = true
    update :deleted_at => Time.now
    comments.all.each(&:destroy_without_paranoid) if self.respond_to?(:comments)
  end

  def recently_restored?
    @recently_restored = true if attribute_dirty?(:deleted_at) && !self.deleted_at
  end
end
