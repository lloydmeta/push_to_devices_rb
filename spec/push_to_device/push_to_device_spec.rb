require 'spec_helper'

describe PushToDevices do

  before(:all) do
    PushToDevices::API.configure do |config|
      config.host = "nowhere.com"
      config.client_id = "fakeclientid"
      config.client_secret = "fakeclientsecret"
      config.use_ssl = false
    end
  end

  describe ".get_service_info" do

    it "should make a request to the proper endpoint" do
      PushToDevices::API.get_service_info
      a_request(:get, "http://nowhere.com/services/me").should have_been_made
    end

  end

  describe ".post_notification_to_user" do

    it "should make a request to the proper endpoint" do
      unique_hash = "1234123412"
      notification_data = {
        ios_specific_fields: {text: "ios"},
        android_specific_fields: {text: "android"}
      }
      PushToDevices::API.post_notification_to_user(unique_hash: unique_hash, notification_data: notification_data)
      a_request(:post, "http://nowhere.com/users/#{unique_hash}/notifications").with(body: notification_data.to_json).should have_been_made
    end
  end

  describe ".post_notification_to_users" do

    it "should make a request to the proper endpoint" do
      unique_hashes = ["1234123412", "asdfasfdfa"]
      notification_data = {
        ios_specific_fields: {text: "ios"},
        android_specific_fields: {text: "android"}
      }
      PushToDevices::API.post_notification_to_users(unique_hashes: unique_hashes, notification_data: notification_data)
      a_request(:post, "http://nowhere.com/users/notifications").with(body: {unique_hashes: unique_hashes, notification_data: notification_data}.to_json).should have_been_made
    end
  end

  describe ".register_user_for_push" do

    it "should make a request to the proper endpoint with the proper body" do
      data = {
        unique_hash: "a unique hash of the user in your service",
        apn_device_token: "an apple ios device token",
        gcm_registration_id: "gcm_registration_id"
       }
       PushToDevices::API.register_user_for_push(data)
      a_request(:post, "http://nowhere.com/users/").with(body: data.to_json).should have_been_made
    end
  end

end