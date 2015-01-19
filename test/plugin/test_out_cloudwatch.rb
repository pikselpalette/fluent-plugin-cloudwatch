require 'helper'
require 'fluent/test'
require 'fluent/plugin/out_cloudwatch'

class CloudWatchTest < Test::Unit::TestCase
  attr_accessor :post_data

  CONFIG_NONE = %[]

  CONFIG_KEYS = %[
    access_key xxxx
    secret_key xxxx
    region eu-west-1
  ]

  CONFIG_PROFILE = %[
    instance_profile true
    region eu-west-1
  ]

  def record
    {
      "Dimensions" => [{"Name" => "InstanceId", "Value" => "i-12345"}],
      "Metric" => "app_concurrents",
      "Value" => 100,
      "Unit" => "Milliseconds",
      "Timestamp" => "2015-01-19T15:30:09+0000",
      "Namespace" => "local/myapp",
    }
  end

  def create_driver(conf = CONFIG_NONE, tag='cloudwatch')
    ENV['testing'] = 'true'
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::CloudWatchOutput, tag).configure(conf)
  end

  def test_configure_keys
    d = create_driver(CONFIG_KEYS)
    assert_equal d.instance.access_key, 'xxxx'
    assert_equal d.instance.secret_key, 'xxxx'
    assert_equal d.instance.instance_profile, false
    assert_equal d.instance.region, 'eu-west-1'
  end

  def test_configure_instance_profile
    d = create_driver(CONFIG_PROFILE)
    assert_equal d.instance.access_key, nil
    assert_equal d.instance.secret_key, nil
    assert_equal d.instance.instance_profile, true
    assert_equal d.instance.region, 'eu-west-1'
  end

  def test_configure_none
    assert_raise(Fluent::ConfigError) { d = create_driver(CONFIG_NONE) }
  end

  def stub_elastic(metrics)
    stub_request(:write, metrics).with do |req|
      @post_data = req.body
    end
  end

  # Waiting for mocking on cloudwatch connections to work
  # def test_post
  #   d = create_driver(CONFIG_KEYS)
  #   d.emit(record)
  #   d.run
  #   assert_equal('myindex', @post_data)
  # end
end
