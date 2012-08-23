require 'yaml'
require 'aws/s3'
require_relative 'load_path'

s3_config = YAML::load(File.open(project_path + '/config/s3.yml'))
s3_config = ENV['RACK_ENV'] == 'production' ? s3_config['production'] : s3_config['development']

AWS::S3::Base.establish_connection!(
	:access_key_id     => s3_config['access_key_id'], 
	:secret_access_key => s3_config['secret_access_key']
)

BUCKET = s3_config['bucket']
	
