ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'shoulda'
require 'rack/test'
require 'shawty'

class ShawtyTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    execute "DELETE FROM #{table_name}"
  end

  def app
    Sinatra::Application
  end

  context "on GET to /" do
    setup {
      get '/'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should "have some kind of welcome" do
      assert last_response.body =~ /to save a url/
    end
  end

  context "on GET to / with url" do
    setup {
      execute %Q{
        INSERT INTO #{table_name} (url, id)
        VALUES (
          #{quote 'http://google.com/'},
          nextval('shawty_id_seq')
        )
      }
      id = execute(%Q{
              SELECT id FROM #{table_name}
              WHERE url = #{quote 'http://google.com/'}
           }).first['id'].to_i

      get "/#{id.alphadecimal}"
    }
    should "return a 301 redirect" do
      assert_equal 301, last_response.status
    end
    should "return Location: header to url" do
      assert_equal 'http://google.com/',
                   last_response.headers['Location']
    end
  end

  context "on POST to /" do
    setup {
      post '/http://some.url/path.ext'
    }
    should "return ok" do
      assert last_response.ok?
    end
    should_change "record count", :by => 1 do
      execute(%Q{ SELECT COUNT(*) FROM #{table_name} }).first['count'].to_i
    end
    should "save the url" do
      res = execute(%Q{
                SELECT * FROM #{table_name}
                WHERE  url = #{quote 'http://some.url/path.ext'}
              })
      assert res.one?, res.map.inspect
    end
  end
end