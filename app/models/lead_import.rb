class LeadImport
  include Mongoid::Document
  include Mongoid::Timestamps
  include Assignable
  include HasConstant
  include HasConstant::Orm::Mongoid

  field :deliminator, default: ','
  field :unimported,  type: Array,    default: []
  field :state,       type: Integer,  default: 0

  validates_presence_of :file, :deliminator, :user

  has_constant :states, %w(pending completed canceled)

  mount_uploader :file, AttachmentUploader

  referenced_in :user

  references_many :imported, class_name: 'Lead', stored_as: :array

  def import
    lines.each_with_index do |line, index|

      if index == 0
        get_included_fields(line)
      else
        values = line.split(deliminator)
        lead = Lead.new(build_attributes(values))
        lead.last_name = 'n/a' if lead.last_name.blank?
        similar = lead.similar(0.9)
        similar_accounts = lead.similar_accounts(0.9)
        unless similar.any? || similar_accounts.any?
          lead.save
          Sunspot.index(lead)
          self.imported << lead
        else
          self.unimported << [line, similar.map(&:id) + similar_accounts.map(&:id)]
        end
        save
      end
    end
    self.state = 'completed'
    save!
    ImportMailer.import_summary(self).deliver
  end

  def lines
    file.read.force_encoding('iso-8859-1').encode('utf-8').split("\r")
  end

  def progress
    (total_imported.to_f / lines.count) * 100
  end

  def total_imported
    imported.count + unimported.count
  end

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
end
