class Search
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :collections, Object, :default => []
  property :terms, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  belongs_to :user, :required => false

  validates_presence_of :terms

  def results(per_page = 30, page = 1)
    @results ||= search(per_page, page).results
  end

  private

  def search(per_page, page)
    Sunspot.search(collections.map(&:constantize)) do
      keywords terms
      paginate(:per_page => per_page, :page => page)
    end
  end
end
