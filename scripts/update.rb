require 'twitter'
require 'mongoid'
require 'open-uri'
require 'nokogiri'
require_relative '../models/hug'
require_relative '../helpers'

root_dir = File.dirname(File.expand_path(__FILE__))
root_dir = File.expand_path(root_dir + '/../')

Mongoid.load!("#{root_dir}/config/mongoid.yml", :production)

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
