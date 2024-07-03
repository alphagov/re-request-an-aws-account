require 'aws-sdk-s3'
require 'cost_centre_reader'

def load_from_s3(bucket, key)
  Rails.logger.info("Loading cost centre data from s3://#{bucket}/#{key}")
  s3 = Aws::S3::Client.new
  response = s3.get_object(
    bucket: bucket,
    key: key
  )
  data = response.body.read
  Rails.logger.info("Fetched #{response.content_length} bytes from s3://#{bucket}/#{key}. Last modified #{response.last_modified}")
  return data
end

data = if ENV.has_key?('COST_CENTRE_S3_BUCKET_NAME')
  load_from_s3(ENV['COST_CENTRE_S3_BUCKET_NAME'], 'cost_centres.csv')
else
  File.read(File.join(Rails.root, 'test', 'fixtures', 'cost_centre_fixture.csv'))
end

COST_CENTRES = CostCentreReader.new(data)
