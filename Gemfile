source 'http://rubygems.org'

gem 'rake'
gem 'activerecord', '~> 3.2'
gem 'sinatra'
gem 'sinatra-contrib', :require => 'sinatra/config_file'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
# gem 'sinatra-logger'
gem 'jsonschema'
gem 'thin'

group :development, :test do
  gem 'sqlite3'
end

group :staging, :production do
  gem 'mysql2'
end


