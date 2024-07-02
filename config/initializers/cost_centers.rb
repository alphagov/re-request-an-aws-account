require 'aws-sdk-s3'
 




if ENV.has_key?('COST_CENTRE_S3_BUCKET_NAME')
    cost_centre_s3_bucket_name = ENV['COST_CENTRE_S3_BUCKET_NAME']
    COST_CENTRES_CSV_LOCATION = File.join(Rails.root, 'tmp', 'cost_centres.csv')
    s3 = Aws::S3::Client.new
    s3.get_object(
        bucket: cost_centre_s3_bucket_name,
        key: 'cost_centres.csv',
        response_target: COST_CENTRES_CSV_LOCATION
    )
else
    COST_CENTRES_CSV_LOCATION = File.join(Rails.root, 'test', 'fixtures', 'cost_centre_fixture.csv')
end
