module ParanoidDelete
  extend ActiveSupport::Concern

  included do
    property :deleted_at, DateTime

    alias_method_chain :destroy, :paranoid
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
    update :deleted_at => Time.now
    comments.destroy! if self.respond_to?(:comments)
  end
end
