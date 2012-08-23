configure :production do
	# Uses Heroku config variables if they are present
	if ENV['MONGOLAB_URL']
		Mongoid.configure do |config|
  	  config.uri = ENV['MONGOLAB_URL']
  	end
	else
  	Mongoid.load!("#{settings.root}/config/mongoid.yml", :production)
	end
	
end

configure :development do
  Mongoid.load!("#{settings.root}/config/mongoid.yml", :development)
end
