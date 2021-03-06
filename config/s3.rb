require 'yaml'
require 'aws-sdk'
require_relative 'load_path'

# Uses Heroku config variables if they are present.
if ENV['AWS_KEY_ID']
	 s3_config = {
			'access_key_id' => ENV['AWS_KEY_ID'],
	 		'secret_access_key' => ENV['AWS_SECRET'],
	 		'bucket' => ENV['AWS_S3_BUCKET']
		}
else
	s3_config = YAML::load(File.open("#{project_path}/config/s3.yml"))
	s3_config = ENV['RACK_ENV'] == 'production' ? s3_config['production'] : s3_config['development']
end

Aws.config.update({
	credentials: Aws::Credentials.new(s3_config['access_key_id'], s3_config['secret_access_key']),
	region: 'us-east-1'
})

BUCKET = s3_config['bucket']
