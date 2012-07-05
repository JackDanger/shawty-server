## Resources
require 'sinatra/base'
require 'active_record'
require 'alphadecimal'
require File.expand_path('../shawty/helpers', __FILE__)

class Shawty < Sinatra::Base
  include Helpers
  extend Helpers

  get '/' do
    %Q{
      <body style='line-height: 1.8em; font-family: Archer, Museo, Helvetica, Georgia; font-size 25px; text-align: center; padding-top: 20%;'>
        Post to '/' to save a url and receive a plaintext short url in response. Example:
        <pre style='font-family: Iconsolata, monospace;background-color:#EEE'>curl -X POST http://#{request.host}/http://some.url/at.someplace</pre>
        <br />
        <form action=/ method=POST onsubmit='if(\"\"==this.url.value)return false;else{this.action=\"/\"+this.url.value}'>
          <input type=text name='url' />
          <input type=submit value='Get Shawty' />
        </form>
        <small>Also, try <a href='http://github.com/JackDanger/shawty-client'>the official Ruby client</a></small>
      </body
  }
  end

  get '/:id' do
    url = select_column %Q{
                    SELECT url FROM #{table_name}
                    WHERE id = #{quote params[:id].alphadecimal.to_i}
                  }

    pass unless url

    redirect url, 301
  end

  post '*' do
    url = request.env['REQUEST_URI'] || Array(params[:splat]).first

    url = url[1, url.size] if url =~ /^\//

    pass if url.nil? || '' == url

    quoted = quote url

    id = select_column %Q{ SELECT id FROM #{table_name} WHERE url = #{quoted} }

    id ||= select_column %Q{
            INSERT INTO #{table_name} (url, id) VALUES (#{quoted}, nextval('shawty_id_seq'))
            RETURNING id
          }

    "http://#{request.host}/#{id.to_i.alphadecimal}"
  end

  ## Environments
  configure :development  do init 'development' end
  configure :test         do init 'test'        end
  configure :production   do init 'production'  end
end
