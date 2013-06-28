require 'mongoid'
require 'open-uri'
require 'nokogiri'
require_relative '../models/hug'
require_relative '../helpers'
require_relative '../config/load_path'
require_relative '../config/twitter'

env = ENV['RACK_ENV'] || 'development'

Mongoid.load!("#{project_path}/config/mongoid.yml", env.to_sym)

def update_hugs!
  puts Time.now
  puts "Updating hugs..."

	terms = ["FridayHug", "HugFriday", "tenderlove hug", "tenderlove hugs"]

	terms.each do |term|
    puts "Search: #{term}"
    Twitter.search(term, include_entities: true, count: 100, result_type: 'recent').results.each do |tweet|
      Hug.create_or_skip(tweet)
			puts tweet.text
    end
    sleep(5)
  end

	puts "Success!"
end

update_hugs!
