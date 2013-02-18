Push to Devices Ruby Client Library
------------------------------

A Ruby client library for [Push to Devices server](https://github.com/lloydmeta/push_to_devices) to make it easier to register users, send notifications to users individually, and send a notification to a bunch of users.

Installation
---------
    $ gem install push_to_devices

or add to your ``Gemfile``

    gem 'push_to_devices'

and install it with

    $ bundle install

Basic Overview
------------

1. Deploy [Push to Devices server](https://github.com/lloydmeta/push_to_devices)
2. Register a service in Push to Devices
3. Take note of the Server and Mobile API credentials from the service
4. Install this Gem
5. Configure the gem according to the credentials in step 3.
6. Interact with the Push to Devices service

Configuration
------------

Simply use a config block.

The example below assumes a typical Rails-like setup (with a YAML file to hold your configuration of the Push to Devices server), but you can use any way you wish to hold your config.

```Ruby
# Load the push_server.yml configuration file
rails_env = `hostname`.chomp == 'petalog_dev' ? "development_petalog" : Rails.env
push_server_config = YAML.load_file(Rails.root + 'config/push_server.yml')[rails_env].symbolize_keys

PushToDevices::API.configure do |config|
  config.api_host = push_server_config[:api_host]
  config.client_id = push_server_config[:client_id]
  config.client_secret = push_server_config[:client_secret]
  config.use_ssl = push_server_config[:use_ssl]
end
```

Examples
--------

1. Getting information about your Service as defined in the Push to Devices server

    `PushToDevices::API.get_service_info`

2. Register a user for push notifications

    ```Ruby
    data = {
      unique_hash: "a unique hash of the user in your service",
      apn_device_token: "an apple ios device token",
      gcm_registration_id: "gcm_registration_id"
     }
     PushToDevices::API.register_user_for_push(data)
    ```

3. Send a notification to a user (Push to Devices server takes care of sending to all the user's devices)

    ```Ruby
    unique_hash = "jkl4h6l4j36h3lj6ghjgk2jh"
    notification_data = {
      ios_specific_fields: {alert: "Hello!", badge: 3},
      android_specific_fields: {title: "Android notification", text: "Hello Android user!"}
    }
    PushToDevices::API.post_notification_to_user(unique_hash: unique_hash, notification_data: notification_data)
    ```

4. Send a notification to a group of users

    ```Ruby
    unique_hashes = ["h1k43jgh14g6hl34j1g6", "1bjhl6b134hj6gl41hj6", ...]
    notification_data = {
      ios_specific_fields: {alert: "Hello!", badge: 3},
      android_specific_fields: {title: "Android notification", text: "Hello Android user!"}
    }
    PushToDevices::API.post_notification_to_users(unique_hashes: unique_hashes, notification_data: notification_data)
    ```

## License

Copyright (c) 2013 by Lloyd Chan

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, and to permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.