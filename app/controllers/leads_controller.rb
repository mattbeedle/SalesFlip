class LeadsController < InheritedResources::Base
  load_and_authorize_resource

  before_filter :resource,          :only => [ :convert, :promote, :reject ]
  before_filter :set_filters,       :only => [ :index, :export ]
  before_filter :export_allowed?,   :only => [ :index ]
  before_filter :already_assigned?, :only => [ :update ]

  cache_sweeper :lead_sweeper

  respond_to :html
  respond_to :xml, :only => [ :new, :create, :index, :show ]
  respond_to :csv, :only => [ :index ]

  has_scope :with_status, :type => :array
  has_scope :unassigned,  :type => :boolean
  has_scope :assigned_to
  has_scope :source_is,   :type => :array

  helper_method :leads_index_cache_key

  def index
    index! do |format|
      format.html
      format.xml
      format.csv do
        fields = params[:fields] || Lead.exportable_fields
        data = "#{fields.sort.join(params[:deliminator] || '|')}\n"
        data += leads.map { |l| l.deliminated(params[:deliminator] || '|', fields) }.join("\n")
        send_data data, :type => 'text/csv'
      end
    end
  end

  def new
    @lead ||= build_resource
    @lead.assignee_id = current_user.id
  end

  def create
    create! do |success, failure|
      success.html { return_to_or_default lead_path(@lead) }
    end
  end

  def update
    params[:lead].merge!(:updater_id => current_user.id)
    update! do |success, failure|
      success.html { return_to_or_default lead_path(@lead) }
    end
  end

  def destroy
    @lead.updater_id = current_user.id
    @lead.destroy
    redirect_to leads_path
  end

  def convert
    @account = current_user.accounts.new(:name => @lead.company)
    @contact = Contact.first(:conditions => { :email => @lead.email }) unless @lead.email.blank?
    @opportunity = current_user.opportunities.build :assignee => current_user
    @opportunity.attachments.build
  end

  def promote
    @lead.updater_id = current_user.id
    @account, @contact, @opportunity = @lead.promote!(
      params[:account_id].blank? ? params[:account_name] : params[:account_id], params)
    if @account.nil? && @contact.valid?
      redirect_to contact_path(@contact)
    elsif @account.valid? && @contact.valid?
      redirect_to account_path(@account)
    else
      render :action => :convert
    end
  end

  def reject
    @lead.updater_id = current_user.id
    @lead.reject!
    redirect_to leads_path
  end

  def export
    set_filters
  end

protected
  def leads_index_cache_key
    Digest::SHA1.hexdigest([
      'leads', Lead.for_company(current_user.company).desc(:updated_at).
      first.try(:updated_at).try(:to_i), params.flatten.join('-')].join('-'))
  end

  def leads
    @leads = apply_scopes(Lead).for_company(current_user.company).not_deleted.
      permitted_for(current_user).desc(:status).desc(:created_at)
  end

  def collection
    unless read_fragment(leads_index_cache_key)
      @page = params[:page] || 1
      @per_page = 10
      @leads ||= hook(:leads_collection, self, :pages => { :page => @page, :per_page => @per_page }).
        last
      @leads ||= leads.paginate(:per_page => @per_page, :page => @page)
    end
  end

  def set_filters
    @filters = {}
    @filters.merge!(:with_status => params[:with_status]) if params[:with_status]
    @filters.merge!(:unassigned => params[:unassigned]) if params[:unassigned]
    @filters.merge!(:assigned_to => params[:assigned_to]) if params[:assigned_to]
    @filters.merge!(:source_is => params[:source_is]) if params[:source_is]
    @filters
  end

  def resource
    @lead ||= hook(:leads_resource, self).last
    @lead ||= Lead.for_company(current_user.company).find(params[:id]) if params[:id]
  end

  def begin_of_association_chain
    current_user
  end

  def build_resource
    if params[:lead] && (ids = params[:lead][:permitted_user_ids]) && ids.is_a?(String)
      params[:lead][:permitted_user_ids] = ids.lines.to_a
    end
    @lead ||= Lead.new({ :updater => current_user, :user => current_user }.merge!(params[:lead] || {}))
  end

  def export_allowed?
    if request.format.csv?
      raise CanCan::AccessDenied unless can? :export, current_user
    end
  end

  def already_assigned?
    if !resource.assignee.blank? && resource.assignee != current_user
      flash[:error] = "This lead was just accepted by " +
        "#{resource.assignee.full_name}, you can no longer accept it"
      redirect_to :back
      return false
    end
  end
end
