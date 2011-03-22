class InstantSearchController < ActionController::Metal
  def search
    term = /^#{Regexp.escape(params[:q])}/

    leads = repository.adapter.select(
      %Q(
      select id, first_name, last_name, company from leads
      where company ~* ? and status != ?
      order by company asc
      limit 5
      ),
      term,
      Lead.statuses.index("Converted") + 1
    )

    leads.map! do |lead|
      {
        :id => lead.id,
        :name => "#{lead.first_name} #{lead.last_name}",
        :company => lead.company
      }
    end

    accounts = repository.adapter.select(
      "select id, name from accounts where name ~* ? order by name asc limit 5",
      term
    )

    accounts.map! do |account|
      { :id => account.id, :name => account.name }
    end

    self.content_type = "application/json"
    self.response_body = {:leads => leads, :accounts => accounts}.to_json
  end
end
