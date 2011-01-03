require 'test_helper.rb'

class AttachmentTest < ActiveSupport::TestCase
  should_require_key :attachment, :subject_id
end
