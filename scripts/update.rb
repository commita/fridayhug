require 'twitter'
require 'mongoid'
require 'open-uri'
require 'nokogiri'
require_relative '../models/hug'
require_relative '../helpers'
require_relative '../config/load_path'

Mongoid.load!("#{project_path}/config/mongoid.yml", :production)

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
