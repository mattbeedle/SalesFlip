# encoding: utf-8
module Exportable
  extend ActiveSupport::Concern

  module ClassMethods

    def export(options = {})
      column_names = options[:column_names] || properties.map(&:name).map(&:to_s)
      File.open(
        "#{Rails.root}/tmp/#{self.to_s.pluralize.underscore}.csv", 'w+',
        encoding: 'UTF-16LE'
      ) do |file|

        file.write "#{column_names.join("\t")}\n"
        all.each do |item|
          line = item.deliminated(options[:deliminator] || "\t", column_names) + "\n"
          file.write line
        end
      end
    end
  end

  def deliminated( deliminator, fields )
    fields.map { |field| "\"#{self.send(field)}\"" }.join(deliminator)
  end
end
