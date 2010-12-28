class Search
  include DataMapper::Resource
  include DataMapper::Timestamps

  property :id, Serial
  property :collections, Object, :default => []
  property :terms, String,
    required: true, message: I18n.t('activemodel.errors.messages.blank')
  property :company, String,
    required: true, message: I18n.t('activemodel.errors.messages.blank')

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
