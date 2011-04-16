require 'test_helper'

class OpportunityTest < ActiveSupport::TestCase

  context "#attributes" do

    setup do
      @attachment = Attachment.make(:erich_offer_pdf)
      @opportunity = Opportunity.make
      @comment = Comment.make
      @opportunity.comments << @comment
      @opportunity.attachments << @attachment
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

    should "include contact first name" do
      assert_equal @contact.first_name, @attributes[:contact]['first_name']
    end

    should 'include contact last name' do
      assert_equal @contact.last_name, @attributes[:contact]['last_name']
    end

    should 'include contact phone' do
      assert_equal @contact.phone, @attributes[:contact]['phone']
    end

    should 'include contact salutation' do
      assert_equal @contact.salutation, @attributes[:contact]['salutation']
    end

    should 'include contact job title' do
      assert_equal @contact.job_title, @attributes[:contact]['job_title']
    end

    should 'include contact id' do
      assert_equal @contact.id, @attributes[:contact]['id']
    end

    should "include contact email" do
      assert_equal @contact.email, @attributes[:contact]['email']
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

    should "include attachments" do
      assert_equal [ @attachment.attachment.url ], @attributes[:attachments]
    end

    should "include salesperson email" do
      assert_equal @opportunity.assignee.email, @attributes[:salesperson_email]
    end
  end
end
