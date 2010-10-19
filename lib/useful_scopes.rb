module UsefulScopes
  def self.included( base )
    base.class_eval do
      if base.respond_to?(:named_scope)
        named_scope :order, lambda { |order, direction| { :order => "#{order} #{direction}" } }
        named_scope :limit, lambda { |limit| { :limit => limit } }
        named_scope :assigned_to, lambda { |user_id| { :where => { :assignee_id => user_id } } }
      end
    end
  end
end
