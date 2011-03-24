require 'test_helper'

class InfomailMailerTest < ActiveSupport::TestCase

  setup do
    @lead = Lead.new
    @template = InfomailTemplate.new
  end

  should "be repliable to the assignee's email" do
    user = User.new(email: "joe@example.test")
    @lead.assignee = user

    assert_equal [user.email], InfomailMailer.mailer(@lead, @template).reply_to
  end

end
