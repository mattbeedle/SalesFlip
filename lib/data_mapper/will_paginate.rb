module DataMapper
  class Collection

    attr_reader :total_entries
    attr_reader :total_pages
    attr_reader :current_page

    # current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end

    def paginate(options = {})
      raise ArgumentError, "parameter hash expected (got #{options.inspect})" unless Hash === options

      page = (options[:page] || 1).to_i
      per_page = (options[:per_page] || 30).to_i

      @total_entries = count
      @total_pages = (@total_entries / per_page.to_f).ceil
      @current_page = page

      query.update(offset: (per_page - 1) * page, limit: per_page)

      self
    end

  end
end
