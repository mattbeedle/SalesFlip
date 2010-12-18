class Administration::PagesController < Administration::AdministrationController

  def index
    @opportunity_stages = current_user.company.opportunity_stages.asc(:percentage).
      not_deleted
  end
end
