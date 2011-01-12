class Search
  include Mongoid::Document
  include Mongoid::Timestamps

  field :terms
  field :collections, :type => Array

  referenced_in :user, :index => true

  validates_presence_of :terms

  def results( per_page = 30, page = 1 )
    @results ||= Sunspot.search(collections.map(&:constantize) || [Account, Contact, Lead, Opportunity]) do
      keywords terms
      paginate(:per_page => per_page, :page => page)
    end.results
  end
end
