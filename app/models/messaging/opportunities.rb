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
      enqueue("opportunities.update", attributes(opportunity))
    end

    # Runs the minion subscriber for updating offer requests.
    #
    # @example Run the offer job.
    #   Opportunities.new.subscribe
    def subscribe
      job "offers.update" do |data|
        id = data.delete("id")
        if id
          opportunity = Opportunity.find(id)
          opportunity.tap { |opp| opp.inbound_update!(data) } if opportunity
        end
      end
    end

    # Get the specific attributes needed by the offer request on the jobboards
    # side.
    #
    # @param [ Opportunity ] opportunity The opportunity.
    #
    # @return [ Hash ] The attributes to send.
    def attributes(opportunity)
      contact = opportunity.contact
      attrs = opportunity.attributes.except(
        :assignee_id, :updater_id, :contact_id, :status, :created_at, :updated_at
      ).tap do |attr|
        attr[:attachments] =
          opportunity.attachments.inject([]) do |attachments, attachment|
            attachments << attachment.attachment.url
          end
        attr[:comments] =
          opportunity.comments.inject([]) do |comments, comment|
            comments << comment.text
          end
        attr[:company] = contact.account.name
        attr[:contact] = contact.name
        attr[:contact_email] = contact.email
      end
    end
  end
end
