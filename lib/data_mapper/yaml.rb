module DataMapper
  module YAML
    Model.append_inclusions self

    # dm-serializer defines it's own to_yaml function, which isn't compatible
    # with delayed_job, so we redefine the default ruby 1.9 version.
    def to_yaml( opts = {} )
      ::YAML::quick_emit( self, opts ) do |out|
        out.map( taguri, to_yaml_style ) do |map|
          to_yaml_properties.each do |m|
            map.add( m[1..-1], instance_variable_get( m ) )
          end
        end
      end
    end

  end
end
