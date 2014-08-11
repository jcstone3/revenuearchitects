require 'raven'

logger = ::Logger.new("log/raven.log")
logger.level = ::Logger::DEBUG

Raven.configure do |config|
  config.logger = logger
  config.current_environment = Rails.env
  # Modify this if your environments are different
  config.environments = %w[ production staging testing ]
  config.tags = { environment: Rails.env }
  config.dsn = 'http://6d5efdeea0ba45acb653f5d7a47da579:d223860646cc41d8844c5de78c249c52@ex.icicletech.com/13'
end
