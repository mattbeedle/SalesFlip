module Administration
  class DuplicatesController < AdministrationController
    def index
      @leads = Lead.all(
        :fields => [:id, :company],
        :duplicate => true,
        :order => :company.asc
      ).not_deleted.paginate(:per_page => 20, :page => params[:page])
    end

    def show
      @lead = Lead.get(params[:id])
    end

    def update
      lead = Lead.get(params[:id])
      keep = Lead.get(params[:keep])
      similar = lead.similar
      rejects  = ([lead] + similar) - [keep]

      keep.update! :duplicate => false,
        company: params[:lead][:company]

      rejects.each do |reject|
        if params[:reassign]
          reject.tasks.update! asset: keep,
            assignee: keep.assignee
        else
          reject.tasks.update! asset: keep
        end
        reject.tasks.clear

        reject.comments.update! commentable: keep
        reject.comments.clear
      end

      rejects.each &:destroy

      redirect_to params[:return_to] || {action: :index}
    end
  end
end
