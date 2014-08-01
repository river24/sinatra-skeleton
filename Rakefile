require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

# load database settings
ActiveRecord::Base.configurations = YAML.load_file(File.dirname(__FILE__) + "/settings/database.yml")
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

# namespace :db do
#   desc "Migrate database"
#   task :migrate do
#     require File.dirname(__FILE__) + "/config/database"
#     ActiveRecord::Migrator.migrate(
#       'db/migrate',
#       ENV["VERSION"] ? ENV["VERSION"].to_i : nil
#     )
#   end

#   desc 'Load the seed data from db/seeds.rb'
#   task :seed do
#     require File.dirname(__FILE__) + "/config/boot"
#     Dir[File.dirname(__FILE__) + "/db/seeds/*.rb"].each do |seed|
#       load(seed) if File.exist?(seed)
#     end
#     # seed_file = File.join(File.dirname(__FILE__), 'db', 'seeds.rb')
#     # load(seed_file) if File.exist?(seed_file)
#   end
# end

