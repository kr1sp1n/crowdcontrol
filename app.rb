require 'rubygems'
require 'sinatra'
require 'compass'
require 'haml'
require 'osc-ruby'

configure do
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = File.join('views', 'stylesheets')
    config.images_dir = File.join('public', 'images')
    config.http_path = "/"
    config.http_images_path = "/images"
    config.http_stylesheets_path = "/stylesheets"
  end
end

# send OSC messages to server localhost on port 8000
$client = OSC::Client.new( 'localhost', 8000 )

get '/' do
  haml :index
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
end

# osc message key after '/osc/' and value is the last element after split
post %r{/osc/([\w\/.]+)} do |c|
  b = c.split('/')
  value = b.pop
  Thread.new do
    osc_send("/#{b.join('/')}", value)
  end
end

helpers do
  def osc_send(key, value)
    # transform string value to Int or Float
    val = (Integer(value) rescue Float(value) rescue false)
    if val
      #type = (val.is_a?(Float)) ? 'f' : 'i'
      message = OSC::Message.new(key, val)
      $client.send(message)
    end
  end
end