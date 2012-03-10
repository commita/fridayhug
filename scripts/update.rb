require 'twitter'
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

def update_hugs!
  puts Time.now
  puts "Updating hugs..."
  terms = ["FridayHug", "HugFriday", "tenderlove hug", "tenderlove hugs"]
  terms.each do |term|
    puts "Search: #{term}"
    Twitter.search(term, include_entities: true, rpp: 50, result_type: "recent").each do |tweet|
      Hug.create_or_skip(tweet)
    end
    sleep(5)
  end
  puts "Success!"
end

update_hugs!
