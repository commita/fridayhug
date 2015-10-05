configure :production do
	# Uses Heroku config variables if they are present
	if ENV['MONGOLAB_URL']
  	Mongoid.load!("#{settings.root}/config/mongoid_heroku.yml", :production)
	else
  	Mongoid.load!("#{settings.root}/config/mongoid.yml", :production)
	end
end

configure :development do
  Mongoid.load!("#{settings.root}/config/mongoid.yml", :development)
end
