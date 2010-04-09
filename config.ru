ENV['RACK_ENV'] ||= 'production'
require 'config'
use GemsAndRdocs, :urls => ['/cache', '/doc'], :root => ::File.directory?("gems") ? "gems" : Gem.dir
use Rack::Compress
run RackRubygems.new