class Import

  attr_accessor :user, :model, :filename, :deliminator, :unimported, :assignee

  def initialize(user, model, file, options = {})
    copy_file_to_tmp(file)
    self.user, self.model, self.deliminator = user, model, (options[:deliminator] || '|')
    self.assignee = options[:assignee]
    self.unimported = []
    @imported = []
  end

  def imported
    Lead.where(:_id.in => @imported)
  end

  def import
    File.read(self.filename).force_encoding('iso-8859-1').encode('utf-8').
      split("\r").each_with_index do |line, index|

      if index == 0
        get_included_fields(line)
      else
        values = line.split(deliminator)
        object = model.new(build_attributes(values))
        similar = object.similar(0.9)
        unless similar.any?
          object.save
          Sunspot.index(object)
          @imported << object.id
        else
          unimported << [line, similar]
        end
      end
    end
    ImportMailer.import_summary(self).deliver
    FileUtils.rm(self.filename)
  end
  alias :perform :import

protected
  def get_included_fields(line)
    @fields ||= line.split(deliminator).map do |field|
      field.downcase.gsub(/\s/, '_')
    end
  end

  def build_attributes(values)
    attributes = { :user => user, :source => 'Imported', :assignee => assignee,
                   :do_not_index => true, :do_not_notify => true }
    @fields.each_with_index do |field, i|
      attributes.merge!(field.to_sym => values[i])
    end
    attributes
  end

  def copy_file_to_tmp(file)
    self.filename = "tmp/#{BSON::ObjectId.new}"
    File.open(filename, 'w+') do |f|
      f.write file.read.force_encoding('iso-8859-1').encode('utf-8')
    end
  end
end
