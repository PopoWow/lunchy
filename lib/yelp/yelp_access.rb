require 'oauth'

module YelpAccess
  SEARCH_PAT   = "/v2/search?term=%s&location=%s"
  BUSINESS_PAT = "/v2/business/%s"

  def self.init_access_token
    yelp_info = EXT_ACCOUNT[:yelp]
    consumer = OAuth::Consumer.new(yelp_info[:consumer_key],
                                   yelp_info[:consumer_secret],
                                   {:site => "http://#{yelp_info[:api_host]}"})
    return OAuth::AccessToken.new(consumer,
                                  yelp_info[:token],
                                  yelp_info[:token_secret])
  end

  # Using this to automatically initialize class variable
  @@access_token = self.init_access_token

  def get_yelp_id(name, address)
    search_uri = SEARCH_PAT % [CGI.escape(name), CGI.escape(address)]
    data = JSON.parse(@@access_token.get(search_uri).body)
    if data["businesses"].empty?
      puts "Failed to find matching yelp item for #{name}"
    else
      if data["businesses"].length > 1
        #debugger
        puts "search uri: #{search_uri}"
        puts "Found more than one match (#{data["businesses"].length}) for #{name}"
      end
      return data["businesses"][0]["id"]
    end
  end

  def get_yelp_business_info(yelp_id)
    if yelp_id and not yelp_id.empty?
      biz_uri = BUSINESS_PAT % yelp_id
      data = JSON.parse(@@access_token.get(biz_uri).body)
    end
  end
end