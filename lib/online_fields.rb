module OnlineFields
  extend ActiveSupport::Concern

  included do
    class_eval do
      field :website
      field :twitter
      field :linked_in
      field :facebook
      field :xing
      field :blog

      validates_format_of :website, :with => /^http/, :allow_blank => true

      before_validation :correct_website_links
    end
  end

  def correct_website_links
    if !self.website.blank? && self.website.match(/^http/)
      self.website = "http://#{self.website}"
    end
  end
end
