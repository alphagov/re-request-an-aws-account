class ProgrammeForm
  include ActiveModel::Model

  attr_reader :programme, :programme_other
  validate :programme_or_other_specified, :programme_and_other_not_both_specified

  validates_format_of :programme,
                      :programme_other,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @programme = params[:programme]
    @programme_other = params[:programme_other]
  end

  def programme_or_other
    is_other ? programme_other : programme
  end

  def is_other
    programme.to_s.empty? || programme == 'Other'
  end

  def programme_or_other_specified
    errors.add(:programme_or_other_specified, 'Programme is required') if programme_or_other.to_s.empty?
  end

  def programme_and_other_not_both_specified
    if !programme.to_s.empty? && programme != 'Other' && !programme_other.to_s.empty?
      errors.add(:programme_or_other_specified, 'Only one of Programme and Other should be set')
    end
  end

end
