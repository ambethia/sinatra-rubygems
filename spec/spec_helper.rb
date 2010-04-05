require 'rubygems'

require File.join(File.dirname(__FILE__), '..', 'config.rb')
require 'spec'
require 'rack/test'
 
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, true
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, true

module RackRubygemsTestHelpers

  def should_match_webrick_behavior(url, server_method, method = :get)
    #webrick
    data = StringIO.new "#{method.to_s.capitalize} #{url} HTTP/1.0\r\n\r\n"
    @webrick_request.parse data
    @webrick.send(server_method, @webrick_request, @webrick_response)
    
    #sinatra
    send(method, url)
    @response = last_response.dup
    @response.should be_ok
    
    #verify
    {
      :status =>          @response.status,
      :content_type =>    @response['Content-Type'] #actual - sinatra
    }.should == {
      :status =>          @webrick_response.status,
      :content_type =>    @webrick_response['Content-Type'] #expected - webrick
    }
  end
  
  def app
    @app
  end

end

Spec::Runner.configure do |config|
  config.before(:each) {
    #mock the gem index
    @source_index = Gem::SourceIndex.from_gems_in File.expand_path(File.dirname(__FILE__) + "/gems")
    Gem::SourceIndex.should_receive(:from_gems_in).any_number_of_times.and_return(@source_index.refresh!)
    
    #sinatra
    @app = Rack::Builder.new {
      use GemsAndRdocs, :urls => ['/cache', '/doc'], :root => Gem.dir
      use Rack::Compress
      run RackRubygems.new
    }
    
    #webrick
    @webrick = Gem::Server.new Gem.dir, (8000 + $$ % 1000), false
    @webrick_request = WEBrick::HTTPRequest.new :Logger => nil
    @webrick_response = WEBrick::HTTPResponse.new :HTTPVersion => '1.0'
  }
  config.include Rack::Test::Methods
  config.include RackRubygemsTestHelpers
end
