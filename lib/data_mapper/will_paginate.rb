module DataMapper
  # This module defines API-compatible pagination methods with will_paginate.
  # The advantage to this implementation is that it doesn't require loading the
  # collection immediately, allowing DataMapper to strategically eager load
  # paginated collections.
  module WillPaginate

    attr_accessor :total_entries
    attr_accessor :total_pages
    attr_accessor :current_page

    # current_page - 1 or nil if there is no previous page
    def previous_page
      current_page > 1 ? (current_page - 1) : nil
    end

    # current_page + 1 or nil if there is no next page
    def next_page
      current_page < total_pages ? (current_page + 1) : nil
    end

    # Paginates a collection according to the options provided.
    #
    # = Options
    #
    #   :page         current page (defaults to 1)
    #   :per_page     results per page (defaults to 30)
    #
    def paginate(options = {})
      raise ArgumentError, "parameter hash expected (got #{options.inspect})" unless Hash === options

      page = (options[:page] || 1).to_i
      per_page = (options[:per_page] || 30).to_i

      @total_entries = count
      @total_pages = (@total_entries / per_page.to_f).ceil
      @current_page = page

      query.update(offset: (page - 1) * per_page, limit: per_page)

      self
    end

  end
end

DataMapper::Collection.send(:include, DataMapper::WillPaginate)
