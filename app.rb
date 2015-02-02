require 'rubygems'
require 'sinatra'
require 'haml'
require 'pry'
require 'mongo'
require 'json/ext'
require 'uri'
require_relative 'flash'

include Mongo

configure do
  enable :sessions
  conn = MongoClient.new("localhost", 27017)
  set :mongo_connection, conn
  set :mongo_db, conn.db('urls')
end


get '/' do
  haml :index
end

helpers do
  include Rack::Utils
 
  def random_string
    rand(36**5).to_s(36)
  end

  def flash
    @flash ||= FlashMessage.new(session)
  end

  def valid_url?(url)
    if url =~ /\A#{URI::regexp(['http', 'https'])}\z/
      true
    else
      false
    end
  end
end

get '/:blob' do
  short_url = params[:blob]
  record = settings.mongo_db['urls'].find({:short_url=>short_url}).first
  if record
    @url = record["url"]
    redirect @url
  else
    redirect to '/'
  end
end

post '/add_url' do
  content_type :json
  if params[:url] && !params[:url].empty? && valid_url?(params[:url])
    url = params[:url]
    short_url = ""
    loop do
      short_url = random_string
      break unless (settings.mongo_db['urls'].find({:short_url=>short_url}).limit(1).first)
    end
    doc = {:url => url, :short_url => short_url}
    new_url = settings.mongo_db['urls'].insert doc
    flash.message = "http://snip.ly/#{short_url}"
    redirect to '/'
  else
    flash.error = "That doesn't seem to be a valid URL."
    redirect to '/'
  end
end
