ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'shoulda'
require 'rack/test'
require 'pp'
require File.expand_path('../lib/shawty', __FILE__)

class ShawtyTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Shawty::Helpers
  extend Shawty::Helpers

  def setup
    execute "DELETE FROM #{table_name}"
  end

  def app
    Shawty
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
      id = select_column %Q{
        INSERT INTO #{table_name} (url, id)
        VALUES (
          #{quote 'http://google.com/'},
          nextval('shawty_id_seq')
        )
        RETURNING id
      }

      get "/#{id.to_i.alphadecimal}"
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
      select_column(%Q{ SELECT COUNT(*) FROM #{table_name} }).to_i
    end
    should "save the url" do
      assert select_column %Q{
                SELECT id FROM #{table_name}
                WHERE  url = #{quote 'http://some.url/path.ext'}
              }
    end
    should "display the shortened url" do
      id = select_column %Q{
                SELECT id FROM #{table_name}
                WHERE  url = #{quote 'http://some.url/path.ext'}
              }
      assert_equal "http://example.org/#{id.to_i.alphadecimal}",
                   last_response.body
    end
    context "with a url that's been saved previously" do
      setup {
        post '/http://some.url/path.ext'
      }
      should "return ok" do
        assert last_response.ok?
      end
      should_not_change "record count" do
        select_column(%Q{ SELECT COUNT(*) FROM #{table_name} }).to_i
      end
    end
  end
end
