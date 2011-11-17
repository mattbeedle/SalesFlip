# encoding: utf-8
module Exportable
  extend ActiveSupport::Concern

  module ClassMethods

    def export
      column_names = properties.map(&:name).map(&:to_s)
      File.open("#{self.to_s.pluralize.underscore}.csv", 'w+') do |file|
        file.write "#{column_names.join(',')}\n"
        all.each do |item|
          file.write item.deliminated('•', column_names) + "\n"
        end
      end
    end
  end

  def deliminated( deliminator, fields )
    fields.map { |field| "\"#{self.send(field)}\"" }.join(deliminator)
  end
end
