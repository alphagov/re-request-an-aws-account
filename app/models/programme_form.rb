class ProgrammeForm
  include ActiveModel::Model

  attr_reader :programme
  validates_each :programme do |record, attr, value|
    record.errors.add attr, 'is required' if value.nil? || value.empty?
  end

  def initialize(hash)
    @programme = hash[:programme]
  end
end