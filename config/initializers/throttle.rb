require 'redis'

redis_conf = YAML.safe_load(File.join(Rails.root, 'config', 'redis.yml'))
REDIS = Redis.new(host: redis_conf['host'], port: redis_conf['port'])

# We will allow a client a maximum of 60 requests in 15 minutes. The following constants need to be defined in throttle.rb
THROTTLE_TIME_WINDOW = 15 * 60
THROTTLE_MAX_REQUESTS = 60
