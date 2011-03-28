require 'test_helper'

class OpportunityTest < ActiveSupport::TestCase

  context "#attributes" do

    setup do
      @opportunity = Opportunity.make
      @comment = Comment.make
      @opportunity.comments << @comment
      @opportunity.save
      @contact = @opportunity.contact
      @account = @contact.account
      @attributes = Messaging::Opportunities.new.attributes(@opportunity)
    end

    should "include comments" do
      assert_equal [ @comment.text ], @attributes[:comments]
    end

    should "include company name" do
      assert_equal @account.name, @attributes[:company]
    end

    should "include contact name" do
      assert_equal @contact.full_name, @attributes[:contact]
    end

    should "include contact email" do
      assert_equal @contact.email, @attributes[:contact_email]
    end

    should "exclude created timestamps" do
      assert_nil @attributes[:created_at]
    end

    should "exclude updated timestamps" do
      assert_nil @attributes[:updated_at]
    end

    should "exclude assignee id" do
      assert_nil @attributes[:assignee_id]
    end

    should "exclude updater id" do
      assert_nil @attributes[:updater_id]
    end

    should "exclude contact id" do
      assert_nil @attributes[:contact_id]
    end
  end
end
