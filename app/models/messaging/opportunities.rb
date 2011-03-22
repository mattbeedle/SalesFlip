module Messaging #:nodoc:
  class Opportunities
    include Minion

    # Take the provided opportunity and stick it on the queue.
    #
    # @example Put the opportunity on the queue.
    #   Offers.new.publish(opportunity)
    #
    # @param [ Opportunity ] opportunity The opportunity.
    def publish(opportunity)
      Minion.enqueue("opportunities.update", attributes(opportunity))
    end

    # Runs the minion subscriber for updating offer requests.
    #
    # @example Run the offer job.
    #   Opportunities.new.subscribe
    def subscribe
      job "offers.update" do |data|
        opportunity = Opportunity.find(data.delete("id"))
        opportunity.tap { |opp| opp.inbound_update!(data) } if opportunity
      end
    end

    def attributes(opportunity)
      attrs = opportunity.attributes.except(
        :assignee_id, :updater_id, :contact_id, :status, :created_at, :updated_at
      ).tap do |attr|
        attr[:comments] =
          opportunity.comments.inject([]) do |comments, comment|
            comments << comment.text
          end
      end
    end
  end
end
