module DataMapper
  module Model
    module Scope
      def query
        if Query === current_scope
          current_scope.dup.freeze
        else
          repository.new_query(self, current_scope).freeze
        end
      end

      protected

      # There is currently a bug in the scoping code for dm-core which hasn't
      # yet been addressed. This is my hack to get everything working as we
      # need it to.
      #
      # [ http://datamapper.lighthouseapp.com/projects/20609/tickets/1354 ]
      def with_scope_with_and(query, &block)
        if Query === query && Query::Conditions::AbstractOperation === query.conditions
          query = query.dup
          scope_stack = self.scope_stack
          scope_stack << query

          begin
            yield
          ensure
            scope_stack.pop
          end

        else
          with_scope_without_and(query, &block)
        end
      end
      alias_method_chain :with_scope, :and

      public
    end
  end
end
