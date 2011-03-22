require 'test_helper.rb'

class UserMailerJobTest < ActiveSupport::TestCase

  context ".perform" do

    setup do
      @mailer = stub
      Lead.expects(:find).with(1).returns(Lead.new)
      UserMailer.expects(:lead_assignment_notification).returns(@mailer)
    end

    should "execute a lead assignment notification" do
      @mailer.expects(:deliver)
      UserMailerJob.perform(1)
    end
  end
end
