module Blurb
  class BaseResource
    def self.profile_request(api_path)
      access_token = Blurb::Token.retrieve()

      request_config = {
          method: :get,
          url: "#{Blurb.active_api_url}#{api_path}",
          headers: {
            :Authorization => "Bearer #{access_token['access_token']}",
            "Content-Type" => "application/json"
          }
        }

      resp = RestClient::Request.execute(request_config)
      return JSON.parse(resp)
    end

    def self.get_request(api_path, opts = {})
      access_token = Blurb::Token.retrieve()

      url = "#{Blurb.active_api_url}#{api_path}"
      url = api_path if opts[:full_path]

      headers_hash = {
        "Authorization" => "Bearer #{access_token['access_token']}",
        "Content-Type" => "application/json",
        "Amazon-Advertising-API-Scope" => Blurb.profile_id
      }

      headers_hash["Content-Encoding"] = "gzip" if opts[:gzip]
      # headers_hash.delete("Authorization") if opts[:no_token]

      request_config = {
          method: :get,
          url: url,
          headers: headers_hash,
          max_redirects: 0
        }

      begin
        resp = RestClient::Request.execute(request_config)
      rescue RestClient::ExceptionWithResponse => err
        # If this happens, then we are downloading a report from the api, so we can simply download the location
        if err.response.code == 307
          return RestClient.get(err.response.headers[:location])
        end
      end

      return JSON.parse(resp)
    end

    def self.post_request(api_path, payload)
      access_token = Blurb::Token.retrieve()

      request_config = {
          method: :post,
          url: "#{Blurb::API_URL}#{api_path}",
          payload: payload.to_json,
          headers: {
            :Authorization => "Bearer #{access_token['access_token']}",
            "Content-Type" => "application/json",
            "Amazon-Advertising-API-Scope" => Blurb.profile_id.to_i
          }
        }

      resp = RestClient::Request.execute(request_config)
      return JSON.parse(resp)
    end
  end
end
