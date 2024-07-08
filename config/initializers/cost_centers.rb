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

def get_cost_centre_data()
  begin
    return load_from_s3(ENV['COST_CENTRE_S3_BUCKET_NAME'], 'cost_centres.csv')
  rescue StandardError
    Rails.logger.error("Failed unable to retrieve cost_centres.csv from s3")
    return File.read(File.join(Rails.root, 'config', 'cost_centre_fixture.csv'))    
  end
end

COST_CENTRES = CostCentreReader.new(get_cost_centre_data())
