require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :name, :start_date, :end_date
    should_validate_presence_of :name
    should_have_one :objective
    should_belong_to :user
    should_have_many :leads, :tasks, :comments
  end
end
