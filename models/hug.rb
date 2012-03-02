require 'mongoid'

class Hug
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :tweet_id
  field :tweet_text
  field :username
  field :media_url
  field :media_display_url
  field :retweet_count, type: Integer
  field :published_at, type: DateTime
  field :published, type: Boolean

  def self.published
    where(published: true)
  end

  def twitpic?
    media_url =~ /twitpic.com/
  end

  def twitpic_full
    media_url.gsub('thumb', 'full')
  end
end
