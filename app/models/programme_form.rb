class ProgrammeForm
  include ActiveModel::Model

  attr_reader :programme

  def initialize(hash)
    @programme = hash[:programme]
  end
end