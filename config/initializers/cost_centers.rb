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

def load_dummy_cost_centres()
  File.read(File.join(Rails.root, 'config', 'cost_centre_fixture.csv'))
end

def running_inside_a_rake_task?
  !defined?(Rails::Server)
end

def get_cost_centre_data()
  # dont load the cost centers from s3 if were not running the server or we're not in RAILS_ENV != production
  if ENV['COST_CENTRE_S3_BUCKET_NAME'].blank? or running_inside_a_rake_task?
    return load_dummy_cost_centres()
  end

  begin
    bucket = ENV['COST_CENTRE_S3_BUCKET_NAME']
    raise 'Failed COST_CENTRE_S3_BUCKET_NAME env var is NOT set' unless bucket

    return load_from_s3(bucket, 'cost_centres.csv')
  rescue Aws::S3::Errors::ServiceError, Aws::Errors::MissingRegionError
    raise "Failed unable to retrieve cost_centres.csv from s3"
  end
end


COST_CENTRES = CostCentreReader.new(get_cost_centre_data())
