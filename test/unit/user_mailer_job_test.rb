require 'test_helper.rb'

class UserMailerJobTest < ActiveSupport::TestCase

  context ".perform" do

    setup do
      Lead.expects(:find).with(1).returns(Lead.new)
      UserMailer.expects(:lead_assignment_notification)
    end

    should "execute a lead assignment notification" do
      UserMailerJob.perform(1)
    end
  end
end
