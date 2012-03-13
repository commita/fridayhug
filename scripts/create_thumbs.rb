require 'mongoid'
require 'open-uri'
require 'nokogiri'
require_relative '../models/hug'
require_relative '../helpers'

Mongoid.configure do |config|
	MONGOLAB_URL = "mongodb://hugfriday:omgitsfridaygivemeahug@ds031087.mongolab.com:31087/hugfriday"
	uri =  URI.parse(MONGOLAB_URL)
	config.master = Mongo::Connection.from_uri(MONGOLAB_URL).db(uri.path.gsub("/", ""))    
end

Hug.desc.all.each do |hug|
	hug.update_attribute(:media_url, hug.twitpic_full) if hug.twitpic?
	puts "Creating thumb for hug ##{hug.id}"
	hug.create_thumb!
end
