Rails.configuration.after_initialize do
  Mongo::Cursor.class_eval do
    add_method_tracer :refill_via_get_more,
'Database/#{collection.name}/get_more'
    add_method_tracer :count,               'Database/#{collection.name}/count'
  end
  Mongo::Collection.class_eval do
    add_method_tracer :find_one,        'Database/#{name}/find_one'
    add_method_tracer :save,            'Database/#{name}/save'
    add_method_tracer :insert,          'Database/#{name}/insert'
    add_method_tracer :remove,          'Database/#{name}/remove'
    add_method_tracer :update,          'Database/#{name}/update'
    add_method_tracer :find_and_modify, 'Database/#{name}/find_and_modify'
    add_method_tracer :map_reduce,      'Database/#{name}/map_reduce'
    add_method_tracer :group,           'Database/#{name}/group'
    add_method_tracer :distinct,        'Database/#{name}/distinct'
    add_method_tracer :count,           'Database/#{name}/count'
  end
end
