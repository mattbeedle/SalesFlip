class AccountsController < InheritedResources::Base
  load_and_authorize_resource :collection => [:export]

  before_filter :merge_updater_id, :only => [ :update ]
  before_filter :parent_account, :only => [ :new ]
  before_filter :similarity_check, :only => [ :create ]
  before_filter :export_allowed?, :only => [ :index ]

  cache_sweeper :account_sweeper

  respond_to :html
  respond_to :xml

  has_scope :unassigned, :type => :boolean
  has_scope :assigned_to
  has_scope :account_type_is
  has_scope :name_like

  helper_method :accounts_index_cache_key

  def index
    index! do |format|
      format.html
      format.xml
      format.csv do
        fields = params[:fields] || Account.exportable_fields
        data = "#{fields.join(params[:deliminator] || '|')}\n"
        data += accounts.map { |a| a.deliminated(params[:deliminator] || '|', fields) }.join("\n")
        send_data data, :type => 'text/csv'
      end
    end
  end

  def create
    create! do |success, failure|
      success.html { return_to_or_default account_path(@account) }
      success.xml { head :ok }
    end
  end

  def update
    update! do |success, failure|
      success.html { return_to_or_default account_path(@account) }
    end
  end

  def destroy
    resource
    @account.updater_id = current_user.id
    @account.destroy
    redirect_to accounts_path
  end

protected
  def accounts_index_cache_key
    Digest::SHA1.hexdigest([
      'accounts', Account.for_company(current_user.company).
      desc(:updated_at).first.try(:updated_at).
      try(:to_i), params.flatten.join('-')].join('-'))
  end

  def accounts
    @accounts = apply_scopes(Account).for_company(current_user.company).
      not_deleted.asc(:name)
  end

  def collection
    unless read_fragment(accounts_index_cache_key)
      @page = params[:page] || 1
      @per_page = 10
      @accounts ||= hook(:accounts_collection, self,
                         :pages => { :page => @page, :per_page => @per_page }).last
      @accounts ||= accounts.paginate(:per_page => @per_page, :page => @page)
    end
  end

  def merge_updater_id
    params[:account].merge!(:updater_id => current_user.id) if params[:account]
  end

  def build_resource
    return @account if defined?(@account)

    attributes = { :assignee_id => current_user.id }
    attributes.merge!(params[:account] || {})

    @account = current_user.accounts.new(attributes)
  end

  def parent_account
    @parent_account ||= Account.get(params[:account_id]) if params[:account_id]
  end

  def similarity_check
    unless params[:similarity_off]
      build_resource
      @similar_accounts ||= Account.for_company(current_user.company).similar_to(@account)
      render :action => :did_you_mean if @similar_accounts.any?
    end
  end

  def export_allowed?
    if request.format.csv?
      raise CanCan::AccessDenied unless can? :export, current_user
    end
  end
end
