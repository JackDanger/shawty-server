class Shawty < Sinatra::Base
  module Helpers

    def select_column sql
      connection.select_rows(sql).flatten.first
    end

    def execute sql
      connection.execute sql
    end

    def quote string
      connection.quote string
    end

    def table_name
      connection.quote_table_name 'shawty'
    end

    def connection
      ActiveRecord::Base.connection
    end

    def initialize_database
      table = execute %Q{select * from pg_tables where tablename = #{quote 'shawty'}}
      return if table.any?
      execute %Q{
        CREATE TABLE #{table_name} (
          id SERIAL PRIMARY KEY,
          url varchar(2048) UNIQUE
        )
      }
    end

    def database_config
      YAML.load(File.read('config/database.yml'))
    end

    def init(environment)
      ActiveRecord::Base.establish_connection database_config[environment]
      initialize_database
    end
  end
end
