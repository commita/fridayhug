require 'sinatra'
require 'haml'
require 'twitter'
require 'mongoid'
require_relative 'models/hug'
require 'awesome_print'

configure do
  Mongoid.configure do |config|
    if ENV['RACK_ENV'] == 'development'
      name = "hugfriday"
      host = "localhost"
      config.master = Mongo::Connection.new.db(name)
    else
      uri =  URI.parse(ENV['MONGOLAB_URL'])
      config.master = Mongo::Connection.from_uri(ENV['MONGOLAB_URL']).db(uri.path.gsub("/", ""))    
    end
  end
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['kris', 'letsgetsomehugs']
  end
end

get '/' do
  @tweets = Hug.desc(:published_at).skip((current_page-1)*20).limit(20).published
  @num_pages =  @tweets.count / 20
  @num_pages += 1 if  @tweets.count % 20 > 0
  haml :index
end

get '/about' do
  haml :about
end

get '/manage-hugs' do
  protected!
  redirect '/'
end

get '/hide/:id' do
  protected!
  @hug = Hug.find params[:id]
  @hug.update_attribute(:published, false)
  redirect '/'
end

get '/remove/:id' do
  protected!
  @hug = Hug.find params[:id]
  @hug.destroy
  redirect '/'
end

get '/process/new/hugs/with/more/love' do
  update_hugs!
  "Success!"
end

get '/process/tenderlove/with/love' do
  total = 0
  max = Twitter.user(params[:user]).statuses_count
  page = 1
  puts "MAX: #{max}"

  while total < max
    tweets = Twitter.user_timeline('tenderlove', include_entities: true, include_rts: true, count: 100, page: page)
    puts "Tweets: #{tweets.count}"
    
    tweets.each do |tweet|
      tweet = tweet.retweeted_status unless tweet.retweeted_status.nil? 
      
      if tweet.media.empty?
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

      if is_a_hug?(tweet.text) && @media_url
        if Hug.where(media_url: @media_url).empty?
          Hug.create(
            tweet_id: tweet.id,
            tweet_text: tweet.text,
            username: tweet.user.screen_name,
            media_url: @media_url,
            media_display_url: @media_display_url,
            retweet_count: tweet.retweet_count,
            published_at: tweet.created_at,
            published: true
          )
        end
      end
    end
    
    total += 100
    page += 1
    puts "TOTAL: #{total}"
    sleep(10)
  end
  "Success!"
end

def is_image?(url)
  url =~ /twitpic.com|yfrog.com|instagr.am/i
end

def get_image_url(url)
  case url
    when /twitpic.com/
      "http://twitpic.com/show/full/#{url.split('/')[3]}"
    when /yfrog.com/
      "http://yfrog.com/#{url.split('/')[3]}:medium"
    when /instagr.am/
      "http://instagr.am/p/#{url.split('/')[4]}/media?size=m"
  end
end

def is_a_hug?(text)
  text =~ /hug|friday/i
end

def current_page
  params[:page].to_i > 0 ? params[:page].to_i : 1
end

def update_hugs!
  terms = ["tenderlove hug", "tenderlove hugs", "#HugFriday"]
  terms.each do |term|
    Twitter.search(term, include_entities: true, rpp: 50, result_type: "recent").each do |tweet|
      if tweet.media.empty?
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
      if is_a_hug?(tweet.text) && @media_url
        if Hug.where(media_url: @media_url).empty?
          Hug.create(
            tweet_id: tweet.id,
            tweet_text: tweet.text,
            username: tweet.from_user,
            media_url: @media_url,
            media_display_url: @media_display_url,
            retweet_count: tweet.retweet_count,
            published_at: tweet.created_at,
            published: true
          )
        end
      end
    end
  end
end
