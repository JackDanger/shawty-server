## Resources
require 'rubygems'
gem 'sinatra', :version => '1.0'
require 'sinatra'
require 'active_record'
gem 'alphadecimal'
require 'alphadecimal'

## Application

get '/' do
  "Post to '/' to save a url and receive a plaintext short url in response\nExample: POST /http://some.url/at.someplace"
end

post '/:url' do
  quoted = quote(params[:url])

  found = execute %Q{ SELECT id FROM #{table_name} WHERE url = #{quoted} }

  if found.empty?
    execute %Q{ INSERT INTO #{table_name} (url, id) VALUES (#{quoted}, nextval('shawty_id_seq')) }
    found = execute %Q{ SELECT MAX(id) from #{table_name} }
  end

  found.first.alphadecimal
end

## Helpers

def execute sql
  ActiveRecord::Base.connection.execute sql
end

def quote string
  ActiveRecord::Base.connection.quote string
end

def table_name
  ActiveRecord::Base.connection.quote_table_name 'shawty'
end

def initialize_database
  table = execute %Q{select * from pg_tables where tablename = #{quote 'shawty'}}
  return if table.any?
  execute %Q{
    CREATE TABLE #{table_name} (
      id SERIAL PRIMARY KEY,
      url varchar(255) UNIQUE
    )
  }
end

def database_config
  YAML.load(File.read('config/database.yml'))
end

## Environments

configure :production do
  ActiveRecord::Base.establish_connection database_config['production']
  initialize_database
end

configure :test do
  ActiveRecord::Base.establish_connection database_config['test']
  initialize_database
end