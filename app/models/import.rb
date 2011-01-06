class Import

  attr_accessor :user, :model, :file, :deliminator, :unimported

  def initialize(user, model, file, deliminator = '|')
    self.user, self.model, self.file, self.deliminator = user, model, file, deliminator
    self.unimported = []
    @imported = []
  end

  def imported
    Lead.where(:_id.in => @imported)
  end

  def import
    file.read.force_encoding('iso-8859-1').encode('utf-8').split("\r").each_with_index do |line, index|
      if index == 0
        get_included_fields(line)
      else
        values = line.split(deliminator)
        object = model.new(build_attributes(values))
        similar = object.similar(0.9)
        unless similar.any?
          object.save
          @imported << object.id
        else
          unimported << [line, similar]
        end
      end
    end
    ImportMailer.import_summary(self).deliver
  end
  alias :perform :import

protected
  def get_included_fields(line)
    @fields ||= line.split(deliminator).map do |field|
      field.downcase.gsub(/\s/, '_')
    end
  end

  def build_attributes(values)
    attributes = { :user => user, :source => 'Imported' }
    @fields.each_with_index do |field, i|
      attributes.merge!(field.to_sym => values[i])
    end
    attributes
  end
end
