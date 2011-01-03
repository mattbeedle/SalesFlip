class Search
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :collections, Object, :default => []
  property :terms, String
  property :company, String
  property :created_at, DateTime
  property :created_on, Date
  property :updated_at, DateTime
  property :updated_on, Date

  validates_presence_of :terms, :if => lambda { |search| search.company.blank? }
  validates_presence_of :company, :if => lambda { |search| search.terms.blank? }

  belongs_to :user, :required => false

  def results
    unless company.blank?
      @results ||= Lead.search { with(:company, company) }.results.not_deleted +
        Account.search { with(:name, company) }.results.not_deleted
    else
      @results ||= Sunspot.search(collections.map(&:constantize) || [Account, Contact, Lead]) do
        keywords terms
      end.results
    end
  end
end
