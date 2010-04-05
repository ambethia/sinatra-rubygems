APP_ROOT = File.expand_path(File.dirname(__FILE__))
LIB_PATH = File.join(APP_ROOT, 'lib')
$:.unshift LIB_PATH
require 'rubygems'
require 'rubygems/server'
require 'rack'
require 'sinatra/base'
require 'yaml'
require 'zlib'
require 'erb'
require 'rubygems/doc_manager'
require 'rack_compress'
require 'gems_and_rdocs'
require 'rack_rubygems'
