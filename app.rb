require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'twitter'
require 'mongoid'
require_relative 'config/config'
require_relative 'models/hug'
require_relative 'helpers'

enable :sessions

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

get '/atom.xml' do
  @hugs = Hug.desc(:published_at).published.limit(50)
  content_type 'application/atom+xml'
  haml(:atom, :format => :xhtml, :escape_html => true, :layout => false)
end

post '/share-hug' do
  if params[:tweet].present?
    tweet_id = params[:tweet].split('/').last.to_i
		begin
      tweet = Twitter.status(tweet_id, include_entities: true)
      hug = Hug.create_or_skip(tweet, true)
      flash[:success] = 'ZOMG! Your hug is amazing! Thank you.'
      redirect '/'
		rescue
			flash[:alert] = 'Sorry, some exception has raised due to programmer laziness or this is not a valid Tweet URL.'
			redirect '/'
    end
  else
    flash[:info] = 'Hey, you need to enter the Tweet URL.'
    redirect '/'
  end
end

get '/hugs/:id' do
  @hug = Hug.find params[:id]
  haml :show, layout: false
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
