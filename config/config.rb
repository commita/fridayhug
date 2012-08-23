configure :production do
	# Uses Heroku config variables if they are present
	if ENV['MONGOLAB_URL']
		Mongoid.configure do |config|
  	  uri =  URI.parse(ENV['MONGOLAB_URL'])
  	  config.master = Mongo::Connection.from_uri(ENV['MONGOLAB_URL']).db(uri.path.gsub("/", ""))    
  	end
	else
  	Mongoid.load!("#{settings.root}/config/mongoid.yml", :production)
	end
	
end

configure :development do
  Mongoid.load!("#{settings.root}/config/mongoid.yml", :development)
end
