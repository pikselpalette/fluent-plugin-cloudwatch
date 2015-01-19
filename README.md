# fluent-plugin-cloudwatch [![Build Status](https://travis-ci.org/sgran/fluent-plugin-cloudwatch.png)](https://travis-ci.org/sgran/fluent-plugin-cloudwatch)

fluentd output plugin to send metrics to cloudwatch

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-cloudwatch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-cloudwatch

## Configuration

#### Example

Event:


###### Use instance_profile

- configuration

  ```
  <match cloudwatch>
    type cloudwatch
    region eu-west-1
    instance_profile true
  </source>
  ```

- input event

  ```
    {
        "Dimensions": [
            {
                "Name": "InstanceId",
                "Value": "i-12345",
            },
        ],
        "Metric": "app_concurrents",
        "Value": 100,
        "Unit": "Milliseconds",
        "Timestamp": "2015-01-19T15:30:09+0000",
        "Namespace": "local/myapp",
    }

  ```

#### Parameter

###### instance_profile
- Default is false
- Whether to use instance profile for authentication

###### access_key
- Default is nil
- Access Key for authentication

###### secret_key
- Default is nil
- Secret Key for authentication

###### region
- Required
- AWS region for metric submission.

One of instance_profile or access_key and secret_key are required.

## Contributing

1. Fork it ( http://github.com/sgran/fluent-plugin-cloudwatch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
