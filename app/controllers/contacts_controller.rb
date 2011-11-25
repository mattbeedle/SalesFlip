class ContactsController < InheritedResources::Base
  load_and_authorize_resource :collection => [:export]

  before_filter :merge_updater_id, :only => [ :update ]
  before_filter :can_export?, :only => [ :index ]

  cache_sweeper :contact_sweeper, :activity_sweeper

  respond_to :html
  respond_to :xml

  has_scope :unassigned, :type => :boolean
  has_scope :assigned_to
  has_scope :source_is
  has_scope :name_like

  helper_method :contacts_index_cache_key

  def index
    index! do |format|
      format.html
      format.xml
      format.csv do
        fields = params[:fields] || Contact.exportable_fields

        Contact.export(
          column_names: params[:fields] || Contact.exportable_fields,
          deliminator: params[:deliminator]
        )

        send_file "#{Rails.root}/tmp/contacts.csv",
          type: 'text/csv'
      end
    end
  end

  def create
    create! do |success, failure|
      success.xml { head :ok }
      success.html { return_to_or_default contact_path(@contact) }
    end
  end

  def destroy
    @contact.updater_id = current_user.id
    @contact.destroy
    redirect_to contacts_path
  end

protected
  def contacts_index_cache_key
    Digest::SHA1.hexdigest([
      'contacts', Contact.not_deleted.
      for_company(current_user.company).desc(:updated_at).first.
      try(:updated_at).try(:to_i), params.flatten.join('-')].join('-'))
  end

  def contacts
    apply_scopes(Contact).not_deleted.asc(:last_name).
      for_company(current_user.company)
  end

  def collection
    unless read_fragment(contacts_index_cache_key)
      @page ||= params[:page] || 1
      @per_page = 10
      @contacts ||= hook(:contacts_collection, self,
                         :pages => { :page => @page, :per_page => @per_page }).last
      @contacts ||= contacts.paginate(:per_page => @per_page, :page => @page)
    end
  end

  def merge_updater_id
    params[:contact].merge!(:updater_id => current_user.id) if params[:contact]
  end

  def build_resource
    return @contact if defined?(@contact)

    attributes = { :assignee_id => current_user.id }
    attributes.merge!(params[:contact] || {})
    attributes.merge!(:account => account) if account

    @contact = current_user.contacts.build attributes
  end

  def account
    @account ||= Account.get(params[:account_id]) if params[:account_id]
  end
  
  def can_export?
    if request.format.csv?
      raise CanCan::AccessDenied unless can?(:export, current_user)
    end
  end
end
