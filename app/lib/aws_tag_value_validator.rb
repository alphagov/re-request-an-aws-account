module AwsTagValueValidator

  # See https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html#tag-conventions
  def self.allowed_chars_regexp
    /\A[\w .:\/=+-@]*\z/
  end

  def self.allowed_chars_message
    "should only consist of alphanumeric characters, spaces and the characters .:/=+-@"
  end
end
