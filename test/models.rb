# Used by test/unit/permission_test
class AssignableModel
  include DataMapper::Resource
  include HasConstant::Orm::DataMapper
  include Permission
  include Assignable
  property :id, Serial
  belongs_to :user, required: false
end

# Used by test/unit/permission_test
class NotAssignableModel
  include DataMapper::Resource
  include HasConstant::Orm::DataMapper
  include Permission
  property :id, Serial
  belongs_to :user, required: false
end
