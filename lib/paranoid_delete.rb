module ParanoidDelete
  extend ActiveSupport::Concern

  included do
    field :deleted_at, :type => Time

    named_scope :not_deleted, :where => { :deleted_at => nil }
    named_scope :deleted, :where => { :deleted_at.ne => nil }

    alias_method_chain :destroy, :paranoid
    before_save :recently_restored?
  end

  def destroy_with_paranoid
    @recently_destroyed = true
    self.deleted_at = Time.now
    save(:validate => false)
    comments.all.each(&:destroy_without_paranoid) if self.respond_to?(:comments)
  end

  def recently_restored?
    @recently_restored = true if changed.include?('deleted_at') && !self.deleted_at
  end
end
