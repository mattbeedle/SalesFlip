class InfomailTemplatesController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  def create
    @infomail_template.save
    respond_with @infomail_template
  end

  def update
    @infomail_template.update(params[:infomail_template])
    respond_with @infomail_template
  end

end
