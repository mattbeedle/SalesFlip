# Note: testing helpers sucks a bag of dicks

# require 'test_helper'
# require 'action_view/test_case'
# require 'action_view/helpers'
# require 'open-uri'
# require 'simple_form'
# require 'action_controller'
# require 'mocha'
# 
# class FormsHelperTest < ActionView::TestCase
# 
#   include FormsHelper
#   include SimpleForm::ActionViewExtensions::FormHelper
#   include SimpleForm::Inputs
# 
# 
#   context "datepicker_for" do
#     setup do
#       @task = Task.new
#       @controller = UsersController.new
#       self.stubs(:controller).returns(@controller)
#       @request = ActionController::TestRequest.new
#       @request.stubs(:host).returns('localhost:3000')
#       @controller.stubs(:request).returns(@request)
#       @response = ActionController::TestResponse.new
#       self.stubs(:controller_name).returns('tasks')
#       self.stubs(:action_name).returns('new')
#     end
# 
#     should "display date inputs" do
#       datepicker = simple_form_for @task do |f|
#         datepicker_for(f, :due_at)
#       end
#       assert_equal  'why wont this work?', datepicker
#     end
#   end  
# end