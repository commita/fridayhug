configure :production do
  Mongoid.configure do |config|
    uri =  URI.parse(ENV['MONGOLAB_URL'])
    config.master = Mongo::Connection.from_uri(ENV['MONGOLAB_URL']).db(uri.path.gsub("/", ""))    
  end
end

configure :development do
  Mongoid.configure do |config|
    name = "hugfriday"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
  end
end
