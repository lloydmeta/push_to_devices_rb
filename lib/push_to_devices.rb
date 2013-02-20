require "net/http"
require "net/https"
require "cgi"

module PushToDevices

  module Config
    VERSION = '0.1.1'
  end

  class Exception < ::StandardError
    attr_accessor :response_code, :response_body

    # Pretty self explanatory stuff here...
    def initialize(response_code, response_body)
      @response_code = response_code
      @response_body = response_body
      super "Response was #{response_code}, #{response_body}"
    end
  end

  module API

    class << self
      attr_accessor :client_id, :client_secret, :user_agent, :use_ssl, :debug, :host, :port, :client_info

      def configure
        # defaults
        client_id = ""
        client_secret = ""
        user_agent = "PushToDevices RB #{PushToDevices::Config::VERSION}"
        use_ssl = true
        debug = true
        host = ""
        port = 80
        client_info = {version: PushToDevices::Config::VERSION}

        yield self
      end

      def get(endpoint, params={})

        # Set up the HTTP connection
        http = Net::HTTP.new(
            host,
            api_port
        )
        http.use_ssl = (use_ssl == true)
        if debug == true
          http.set_debug_output($stdout)
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        uri = self.generate_uri_from_params(endpoint, params)

        # Set up the request
        request = Net::HTTP::Get.new(uri)

        # Set credentials
        client_credentials = generate_client_credentials
        request["server-client-id"] = client_credentials[:client_id]
        request["client-sig"] = client_credentials[:client_sig]
        request["timestamp"] = client_credentials[:timestamp]

        # Fire the package !
        response = http.start {|http|
          http.request request
        }

        self.handle_response(response)
      end

      def post(endpoint, params = {})

        # Set up the HTTP connection
        http = Net::HTTP.new(
            host,
            api_port
        )
        http.use_ssl = (use_ssl == true)
        if debug == true
          http.set_debug_output($stdout)
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        request = Net::HTTP::Post.new("/"+endpoint, initheader = {'Content-Type' =>'application/json'})
        request.body = params.to_json

        # Set credentials
        client_credentials = generate_client_credentials
        request["server-client-id"] = client_credentials[:client_id]
        request["client-sig"] = client_credentials[:client_sig]
        request["timestamp"] = client_credentials[:timestamp]

        # Fire the package !
        response = http.start {|http|
          http.request request
        }

        self.handle_response(response)
      end

      def api_port
        if port
          port
        else
          use_ssl ? 443 : 80
        end
      end

      def generate_uri_from_params(endpoint, params)
        if params.empty?
          "/#{endpoint}"
        else
          query_string = params.map {|k, v|
            "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
          }.join("&")
          "/#{endpoint}?#{query_string}"
        end
      end

      def generate_client_credentials
        timestamp_s = Time.now.to_i.to_s
        {
          client_id: client_id,
          client_sig: self.generate_client_sig(timestamp_s),
          timestamp: timestamp_s
        }
      end

      def generate_client_sig(timestamp_s)
        OpenSSL::HMAC.hexdigest 'sha1', client_secret, timestamp_s
      end

      def handle_response(response)
        if response.code.to_i != 200
          raise PushToDevices::Exception.new(response.code, response.body)
        else
          response.body
        end
      end

      # GETS to service/me
      # Returns the body
      def get_service_info(params = {})
        self.get('services/me')
      end

      # POSTS to users/:unique_hash/notifications
      # to create a notification for a user
      # Expects the following
      # {
      #   unique_hash: a unique hash of the user in your service,
      #   notification_data: a hash with the following
      #     {
      #       ios_specific_fields: a hash of what you want to send to your ios users,
      #       android_specific_fields: a hash of whaty ou want to send to your android users
      #                                            separated into {data: {}, options: {}}
      #     }
      # }
      def post_notification_to_user(params = {})
        self.post("users/#{params.delete(:unique_hash)}/notifications", params.delete(:notification_data))
      end

      # POSTS to users/notifications
      # to create a notification for a group of users
      # Expects the following
      # {
      #   unique_hashes: an array of unique hashes
      #   notification_data: a hash with the following
      #     {
      #       ios_specific_fields: a hash of what you want to send to your ios users,
      #       android_specific_fields: a hash of whaty ou want to send to your android users
      #                                            separated into {data: {}, options: {}}
      #     }
      # }
      def post_notification_to_users(params = {})
        self.post("users/notifications", params)
      end

      # POSTS to users/ to register a user for push notifications
      # Expects the following
      # {
      #   unique_hash: a unique hash of the user in your service,
      #   apn_device_token: an apple ios device token,
      #   gcm_registration_id: gcm_registration_id
      #  }
      def register_user_for_push(params = {})
        self.post("users/", params)
      end
    end

  end
end