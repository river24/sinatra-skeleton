require 'time'
require 'uri'
require 'base64'
require 'digest/sha1'
require 'json'
require 'logger'

require 'rubygems'
require 'bundler'

Bundler.require(:default)

set :environments, %w{development test staging production}

if settings.environments.include?(ENV['RACK_ENV'])
  print "'#{ENV['RACK_ENV']}' is set as ENV['RACK_ENV']. It is valid.\n"
  Bundler.require(ENV['RACK_ENV'])
else
  print "'#{ENV['RACK_ENV']}' is set as ENV['RACK_ENV']. It is not valid.\n"
  print "Please select from #{settings.environments} and set it as ENV['RACK_ENV'].\n"
  print "Abort!\n"
  exit
end

set :root, ::File.dirname(__FILE__)
set :public_folder, ::File.dirname(__FILE__) + "/public"
set :views, ::File.dirname(__FILE__) + "/app/views"

# load config_files
Dir[File.dirname(__FILE__) + "/settings/*.yml"].each {|setting_yml|
  if setting_yml =~ Regexp.new(".*/database.yml$")
    ActiveRecord::Base.configurations = YAML.load_file(setting_yml)
    ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])
  else
    config_file setting_yml
  end
}

# require models
Dir[File.dirname(__FILE__) + "/app/models/*.rb"].each {|model|
  require model
}

# require helpers
Dir[File.dirname(__FILE__) + "/app/helpers/*.rb"].each {|helper|
  require helper
}

# hack for keep(re-establish) mysql connection
if ActiveRecord::Base.configurations[ENV['RACK_ENV']]['adapter'] == 'mysql2'
  Thread.new {
    loop {
      sleep(60*30)
      ActiveRecord::Base.verify_active_connections!
    }
  }.priority = -10
end

use ::Rack::MethodOverride

# logger
configure :development, :test do
  AppLogger = ::Logger.new(STDOUT)
  AppLogger.level = settings.app_logger_level

  ActiveRecord::Base.logger = ::Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = settings.db_logger_level
end

configure :staging, :production do
  AppLogger = ::Logger.new("#{settings.root}/log/#{settings.environment}_app.log", 'daily')
  AppLogger.level = settings.app_logger_level

  rack_logger = ::Logger.new("#{settings.root}/log/#{settings.environment}_rack.log", 'daily')
  rack_logger.instance_eval do
    alias :write :'<<'
  end
  # def rack_logger.write(msg)
  #   self << msg
  # end
  use Rack::CommonLogger, rack_logger

  ActiveRecord::Base.logger = ::Logger.new("#{settings.root}/log/#{settings.environment}_db.log", 'daily')
  ActiveRecord::Base.logger.level = settings.db_logger_level
end

# helper for logger
helpers do
  def logger
    if defined?(AppLogger)
      AppLogger
    else
      env['rack.logger']
    end
  end
end

before do
  @request = request
  @errors = []
end

# load controllers
Dir[File.dirname(__FILE__) + "/app/controllers/*.rb"].each {|controller|
  load controller
}

after do
  cache_control :no_cache
end

run Sinatra::Application

