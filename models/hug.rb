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

  def self.create_or_skip(tweet, skip_hug_validation = false)
    if tweet.media && tweet.media.empty?
      tweet.expanded_urls.each do |expanded_url|
        if is_image?(expanded_url)
          @media_url = get_image_url(expanded_url)
          @media_display_url = expanded_url
        end
      end
    else
      @media_url = tweet.media.first.media_url
      @media_display_url = tweet.media.first.display_url
    end
    if (is_a_hug?(tweet.text) || skip_hug_validation) && @media_url
      if where(media_url: @media_url).empty?
        user = tweet.from_user.nil? ? tweet.user.screen_name : tweet.from_user
        create(
          tweet_id: tweet.id,
          tweet_text: tweet.text,
          username: user,
          media_url: @media_url,
          media_display_url: @media_display_url,
          retweet_count: tweet.retweet_count,
          published_at: tweet.created_at,
          published: true
        )
      end
    end
  end
  
  def twitpic?
    media_url =~ /twitpic.com/
  end

  def twitpic_full
    media_url.gsub('thumb', 'full')
  end

end
