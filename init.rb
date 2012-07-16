require_relative 'lib/base'

# Use db/development.db by default
# Allow the user to set an environment variable to use a different database
DB.database_file = ENV.fetch('DATABASE') { 'db/development.db' }
