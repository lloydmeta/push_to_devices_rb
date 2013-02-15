require "net/http"
require "net/https"
require "active_support/core_ext/module/attribute_accessors"
require "cgi"

module PushToDevice

  module Config
    VERSION = '0.01'
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

    mattr_accessor :client_id
    @@client_id = ""

    mattr_accessor :client_secret
    @@client_secret = ""

    mattr_accessor :user_agent
    @@user_agent = "PushToDevice RB #{PushToDevice::Config::VERSION}"

    mattr_accessor :use_ssl
    @@use_ssl = true

    mattr_accessor :debug
    @@debug = true

    mattr_accessor :api_host
    @@api_host = ""

    mattr_accessor :client_info
    @@client_info = {version: PushToDevice::Config::VERSION}

    def self.configure
      yield self if block_given?
    end

    def self.get(endpoint, params={})

      # Set up the HTTP connection
      http = Net::HTTP.new(
          @@api_host,
          @@use_ssl == true ? 443 : 80
      )
      http.use_ssl = (@@use_ssl == true)
      if @@debug == true
        http.set_debug_output($stdout)
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if params.empty?
        uri="/"+endpoint
      else
        query_string = params.map {|k, v|
          "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
        }.join("&")
        uri = "/"+endpoint+"?"+query_string
      end

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

    def self.post(endpoint, params = {})

      # Set up the HTTP connection
      http = Net::HTTP.new(
          @@api_host,
          @@use_ssl == true ? 443 : 80
      )
      http.use_ssl = (@@use_ssl == true)
      if @@debug == true
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

    def self.generate_client_credentials
      timestamp_s = Time.now.to_i.to_s
      {
        client_id: @@client_id,
        client_sig: self.generate_client_sig(timestamp_s),
        timestamp: timestamp_s
      }
    end

    def self.generate_client_sig(timestamp_s)
      OpenSSL::HMAC.hexdigest 'sha1', @@client_secret, timestamp_s
    end

    def self.handle_response(response)
      if response.code.to_i != 200
        raise PushToDevice::Exception.new(response.code, response.body)
      else
        response.body
      end
    end

    # GETS to service/me
    # Returns the body
    def self.get_service_info(params = {})
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
    def self.post_notification_to_user(params = {})
      self.post("users/#{params.delete(:unique_hash)}/notifications", params.delete(:notification_data))
    end

    # POSTS to users/ to register a user for push notifications
    # Expects the following
    # {
    #   unique_hash: a unique hash of the user in your service,
    #   apn_device_token: an apple ios device token,
    #   gcm_registration_id: gcm_registration_id
    #  }
    def self.register_user_for_push(params = {})
      self.post("users/", params)
    end

  end
end