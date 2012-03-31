require 'nokogiri'

def is_image?(url)
  url =~ /twitpic.com|yfrog.com|instagr.am|img.ly|.jpg|.jpeg|.gif|.png/i
end

def get_image_url(url)
  case url
    when /twitpic.com/i
      "http://twitpic.com/show/full/#{url.split('/')[3]}"
    when /yfrog.com/i
      "http://yfrog.com/#{url.split('/')[3]}:medium"
    when /instagr.am/i
      "http://instagr.am/p/#{url.split('/')[4]}/media?size=m"
    when /img.ly/i
      get_imgly_url(url)
		when /ow.ly/i
			"http://static.ow.ly/photos/normal/#{url.split('/')[4]}.jpg"
		when /.jpg|.jpeg|.gif|.png/i
			url
  end
end

def get_imgly_url(url)
  doc = Nokogiri::HTML(open(url))
  image_url = doc.search("li[@id='button-fullview']/a").first['href']
  image_id = image_url.split('/')[2]
  image_url = "http://s3.amazonaws.com/imgly_production/#{image_id}/medium.jpg"
end

def is_a_hug?(text)
  text =~ /hug|friday/i
end

def current_page
  params[:page].to_i > 0 ? params[:page].to_i : 1
end

