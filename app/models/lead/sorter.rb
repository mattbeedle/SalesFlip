class Lead
  class Sorter < BasicObject

    attr_accessor :collection

    Direction = ::DataMapper::Query::Direction

    def initialize(collection)
      @collection = collection
    end

    def sort_by(field, direction)
      sorted_collection = case field.to_s
      when "campaign"
        sql = "(select name from campaigns where id = leads.campaign_id)"
        collection.all(:order => Direction.new(sql, direction))

      when "assignee"
        sql = "(select email from users where id = leads.assignee_id)"
        collection.all(:order => Direction.new(sql, direction))

      when "tasks"
        sql = <<-SQL.compress_lines
        ( select due_at::date from tasks
          where lead_id = leads.id and tasks.completed_at is null
          order by due_at asc limit 1 )
        SQL
        collection.all(:order => Direction.new(sql, direction))

      when "comments"
        sql = "(select count(*) from comments where lead_id = leads.id)"
        collection.all(:order => Direction.new(sql, direction))

      when "company"
        collection.all(:order => [
          Direction.new("trim(leading ' \t' from lower(company))", direction)
        ])

      when "name"
        collection.all(:order => [
          Direction.new("trim(leading ' \t' from lower(last_name))", direction),
          Direction.new("trim(leading ' \t' from lower(first_name))", direction)
        ])

      else
        collection.all(:order => [field.to_sym.send(direction)])

      end

      if field != "name"
        sorted_collection.query.order.push(
          Direction.new("trim(leading ' \t' from lower(last_name))", :asc),
          Direction.new("trim(leading ' \t' from lower(first_name))", :asc)
        )
      end

      sorted_collection
    end

  end
end
