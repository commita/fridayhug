require 'mongoid'
require 'open-uri'
require 'mini_magick'
require_relative '../config/s3.rb'

class Hug
  include Mongoid::Document
  include Mongoid::Timestamps

  field :tweet_id
  field :tweet_text
  field :username
  field :media_url
  field :media_display_url
  field :thumb_file_name
  field :retweet_count, type: Integer
  field :published_at, type: DateTime
  field :published, type: Boolean

	IMAGE_TMP_PATH = '/tmp/'

  def self.published
    where(published: true)
  end

  def self.create_or_skip(tweet, skip_hug_validation = false)
    if tweet.media && tweet.media.empty?
      tweet.urls.each do |expanded_url|
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
        hug = create(
          tweet_id: tweet.id,
          tweet_text: tweet.text,
          username: user,
          media_url: @media_url,
          media_display_url: @media_display_url,
          retweet_count: tweet.retweet_count,
          published_at: tweet.created_at,
          published: true
        )
				begin
					hug.create_thumb!
				rescue Exception => e
					hug.destroy
					raise 'Unable to create thumb.'
				end
			end
    end
  end

  def twitpic?
    media_url =~ /twitpic.com/
  end

  def twitpic_full
    media_url.gsub('thumb', 'full')
  end

	def thumb_url
		"https://s3.amazonaws.com/#{BUCKET}/#{tweet_id}/#{thumb_file_name}"
	end

	def create_thumb!
		tmp_file_name = get_image
		img = MiniMagick::Image.open(IMAGE_TMP_PATH+tmp_file_name)
		img.resize('260')
		thumb_name = 'thumb'+'.'+img[:format].downcase.gsub('jpeg', 'jpg')
		self.update_attribute :thumb_file_name, thumb_name
		img.write IMAGE_TMP_PATH+thumb_name

		s3 = Aws::S3::Resource.new
		s3_file = s3.bucket(BUCKET).object(tweet_id.to_s+'/'+thumb_name)
		s3_file.upload_file(open(IMAGE_TMP_PATH+thumb_name), acl: 'public-read')
	end

	def get_image
		file_name = tweet_id.to_s+'.image'
		open(IMAGE_TMP_PATH+file_name, "wb") do |file|
			file.write(open(media_url).read)
		end
		file_name
	end

end
