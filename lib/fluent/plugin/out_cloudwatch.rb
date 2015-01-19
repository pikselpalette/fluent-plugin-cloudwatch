require 'fog'

class Fluent::CloudWatchOutput < Fluent::BufferedOutput
  class ConnectionFailure < StandardError; end
  Fluent::Plugin.register_output('cloudwatch', self)


  config_param :instance_profile, :bool, default: false
  config_param :access_key, :string, default: nil
  config_param :secret_key, :string, default: nil
  config_param :region, :string

  # Define `log` method for v0.10.42 or earlier
  unless method_defined?(:log)
    define_method(:log) { $log }
  end

  def initialize
    super
  end

  def client
    if @instance_profile
      Fog::AWS::CloudWatch.new(:use_iam_profile => true, :region => @region)
    else
      Fog::AWS::CloudWatch.new(:aws_access_key_id => @access_key, :aws_secret_access_key => @secret_key, :region => @region)
    end
  end

  def start
    super
  end

  def shutdown
    super
  end

  def configure(conf)
    super

    unless @instance_profile
      unless @access_key && @secret_key
        raise Fluent::ConfigError, 'out_cloudwatch: Need to specify either instance_profile or both access_key and secret_key'
      end
    end
  end

  def format(tag, time, record)
    [tag, time, record].to_msgpack
  end

  def write(chunk)
    chunk.msgpack_each { |tag, time, record|
      next unless record
      post(record)
    }
  end

  def post(metrics)
    retries = 0
    begin
      client.put_metric_data(metrics['Namespace'], [{
	      "MetricName" => metrics["Metric"],
	      "Value"      => metrics["Value"],
	      "Unit"       => metrics["Unit"],
	      "Timestamp"  => metrics["Timestamp"],
	      "Dimensions" => metrics["Dimensions"],
    }])

    rescue Exception => e
      if retries < 2
        retries += 1
        log.warn "Could not push metrics to Cloudwatch, resetting connection and trying again. #{e.message}"
        sleep 2**retries
        retry
      end
      raise ConnectionFailure, "Could not push metrics to Cloudwatch after #{retries} retries. #{e.message}"
    end
  end
end
