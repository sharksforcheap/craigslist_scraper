# run 'rake -T' to see all available rake tasks

# Putting this in your Rakefile will allow you
# to run your specs via the 'rake spec' command
require 'rspec/core/rake_task'

# This sets up the RSpec-related rake tasks and  tells 
# them to look in the './spec' directory for the spec files
RSpec::Core::RakeTask.new(:spec)

def reset_database(database_file, schema = 'schema.sql')
  system("sqlite3 db/#{database_file} < db/#{schema}")
end

namespace :db do
  desc "Reset db/development.db using db/schema.sql"
  task :reset do
    reset_database('development.db')
  end
  
  namespace :test do
    desc "Reset db/test.db using db/schema.sql"
    task :reset do
      reset_database('test.db')
    end
  end  
end

# This makes rake run the 'db:test:reset'
# before we run rake spec
task :spec => 'db:test:reset'

# This tells rake that the default task is 'rake spec'.
# Instead of typing 'rake spec' we can just type 'rake'.
task :default => :spec
