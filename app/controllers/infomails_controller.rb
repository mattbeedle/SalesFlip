class InfomailsController < ApplicationController

  def create
    if infomail_template
      lead.update :status => "Infomail Sent"
      InfomailMailer.mailer(lead, infomail_template).deliver

      respond_to do |format|
        format.js { render :text => "true" }
        format.html { redirect_to lead_path(lead) }
      end
    else
      render :new
    end
  end

  private

  def infomail_templates
    @infomail_templates ||= InfomailTemplate.all.asc(:name)
  end
  helper_method :infomail_templates

  def lead
    @lead ||= Lead.get(params[:lead_id])
  end
  helper_method :lead

  def infomail_template
    @infomail_template ||= InfomailTemplate.get(params[:infomail][:template])
  end

end
