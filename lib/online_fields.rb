module OnlineFields
  extend ActiveSupport::Concern

  included do
    class_eval do
      property :website, String
      property :twitter, String
      property :linked_in, String
      property :facebook, String
      property :xing, String
      property :blog, String

      validates_format_of :website, :with => /^http/, :allow_blank => true

      before :valid? do
        correct_website_links
      end
    end
  end

  def correct_website_links
    if !self.website.blank? && !self.website.match(/^http/)
      self.website = "http://#{self.website}"
    end
  end
end
