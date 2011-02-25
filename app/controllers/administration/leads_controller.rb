module Administration
  class LeadsController < AdministrationController
    def index
      params[:statuses] ||= I18n.t(:lead_statuses, :locale => :en)

      if params[:terms].present?
        @leads = Lead.search do
          keywords params[:terms]
          paginate(:per_page => 100, :page => params[:page])
        end.results
      else
        @leads = Lead::Sorter.new(params[:sort])
          .all(:status => params[:statuses])
          .paginate(:per_page => 100, :page => params[:page])
      end
    end

    def assignee
      Lead.all(:id => params[:leads]).update!(:assignee_id => params[:assignee_id])
      redirect_to request.referrer
    end

    def campaign
      Lead.all(:id => params[:leads]).update!(:campaign_id => params[:campaign_id])
      redirect_to request.referrer
    end

    def update_status
      Lead.all(:id => params[:leads]).update!(:status => params[:status])
      redirect_to request.referrer
    end

    def source
      Lead.all(:id => params[:leads]).update!(:source => params[:source])
      redirect_to request.referrer
    end

    def rating
      Lead.all(:id => params[:leads]).update!(:rating => params[:rating])
      redirect_to request.referrer
    end

  end
end
