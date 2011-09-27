module CF # :nodoc: all
  module Client # :nodoc: all

    extend ActiveSupport::Concern 

    module ClassMethods
      def default_params
        {:api_key => CF.api_key}
      end

      def get(*args)
        if args.length > 1
          handle_response RestClient.get("#{CF.api_url}#{CF.api_version}#{args.first}", :params => default_params.merge!(args.last), :accept => 'json'){ |response, request, result| response }
        else
          handle_response RestClient.get("#{CF.api_url}#{CF.api_version}#{args.first}", :params => default_params, :accept => 'json'){ |response, request, result| response }
        end
      end

      def post(*args)
        if args.length > 1
          handle_response  RestClient.post("#{CF.api_url}#{CF.api_version}#{args.first}", args.last.merge!(default_params), :accept => 'json'){ |response, request, result| response }
        else
          handle_response  RestClient.post("#{CF.api_url}#{CF.api_version}#{args.first}", default_params, :accept => 'json'){ |response, request, result| response }
        end
      end

      def put(*args)
        handle_response  RestClient.put("#{CF.api_url}#{CF.api_version}#{args.first}", args.last.merge!(default_params), :accept => 'json'){ |response, request, result| response }
      end

      def delete(*args)
        if args.last == {:forced=>true}
          handle_response  RestClient.delete("#{CF.api_url}#{CF.api_version}#{args.first}?api_key=#{CF.api_key}&&forced=true", :accept => 'json'){ |response, request, result| response }
        else
          handle_response  RestClient.delete("#{CF.api_url}#{CF.api_version}#{args.first}?api_key=#{CF.api_key}", :accept => 'json'){ |response, request, result| response }
        end
      end

      def handle_response(response)
        unless response.length == 2
          parsed_response = JSON.load(response)
          if parsed_response.is_a?(Array)
            return parsed_response
          else
            parsed_resp = parsed_response.merge("code" => response.code)
            new_response = parsed_resp.inject({ }) do |x, (k,v)|
              x[k.sub(/\A_/, '')] = v
              x
            end
            return new_response
          end
        else
          JSON.load(response)
        end
      end
    end
  end
end