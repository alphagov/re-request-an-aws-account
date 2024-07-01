require 'aws-sdk-s3'

class CSVRetriever
    def self.get_csv_file(bucket_name, file_name)
      s3 = Aws::S3::Client.new
  
      begin
        obj = s3.get_object(bucket: bucket_name, key: file_name)
        csv_content = obj.body.read
        return csv_content
      rescue Aws::S3::Errors::ServiceError => e
        puts "Error retrieving CSV file from S3: #{e.message}"
        return nil
      end
    end
  end