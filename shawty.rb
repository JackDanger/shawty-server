## Resources
require 'rubygems'
gem 'sinatra', :version => '1.0'
require 'sinatra'
require 'active_record'
gem 'alphadecimal'
require 'alphadecimal'

## Application

get '/' do
  "Post to '/' to save a url and receive a plaintext short url in response" +
  "<br />" +
  "Example: POST /http://some.url/at.someplace" +
  "<br />" +
  "<form action=/ method=POST onsubmit='if(\"\"==this.url.value)return false;else{this.action=\"/\"+this.url.value}'><input type=text name='url' /><input type=submit value='Get Shawty' /></form>"
end

get '/:id' do
  pass unless url = find_url_by_id(params[:id].alphadecimal)

  redirect url, 301
end

post '*' do
  pass if params[:splat].empty?

  url = params[:splat].first
  url = url[1, url.size] if url.chars.first == '/'

  pass if url.empty?

  quoted = quote url

  found = execute %Q{ SELECT id FROM #{table_name} WHERE url = #{quoted} }

  if found.any?
    id = found.first['id']
  else
    connection.transaction do
      found = execute %Q{
          INSERT INTO #{table_name} (url, id) VALUES (#{quoted}, nextval('shawty_id_seq'));
          SELECT MAX(id) from #{table_name}
        }
    end
    id = found.first['max']
  end

  "http://#{request.host}/#{id.alphadecimal}"
end


## Helpers

def find_url_by_id(id)
  result = execute %Q{ SELECT url FROM #{table_name} WHERE id = #{quote id.to_i} }
  return result.map.first['url'] if result.map.length > 0
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
      url varchar(255) UNIQUE
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


## Environments

configure :development  do init 'development' end
configure :test         do init 'test'        end
configure :production   do init 'production'  end