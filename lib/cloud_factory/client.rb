module CloudFactory
  module Client
    extend ActiveSupport::Concern
    include HTTParty
    base_uri "#{CloudFactory.api_url}#{CloudFactory.api_version}"
    headers "accept" => "application/json"
    format :json
    default_params :api_key => CloudFactory.api_key, :email => CloudFactory.email
    
    
    # def subscriptions(query={})
    #   self.class.get("/users/subscriptions.json", :query => query)
    # end
    
    
    # module ClassMethods
    # # class << self
    #   def get(*args); handle_response super end
    # 
    #   def post(*args); handle_response super end
    # 
    #   def handle_response(response)
    #     case response.code
    #     when 401; raise Unauthorized.new
    #     when 403; raise RateLimitExceeded.new
    #     when 404; raise NotFound.new
    #     when 400...500; raise ClientError.new
    #     when 500...600; raise ServerError.new(response.code)
    #     else; response
    #     end
    #     if response.is_a?(Array)
    #       response.map{|item| Hashie::Mash.new(item)}
    #     else
    #       Hashie::Mash.new(response)
    #     end
    #   end
    # end
    
    
  end
end