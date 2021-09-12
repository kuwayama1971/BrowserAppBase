# -*- coding: utf-8 -*-
require "sinatra"
require "sinatra/contrib"
require "sinatra-websocket"
require "thin"
require "json"

require "./server"
require "./wsserver"

get "/" do
  File.read("index.html")
end

get "/css/:name.css" do
  content_type "text/css", :charset => "utf-8"
  puts "css/#{params[:name]}.css"
  File.read "css/#{params[:name]}.css"
end

get "/js/:name.js" do
  content_type "text/javascript", :charset => "utf-8"
  puts "js/#{params[:name]}.js"
  File.read "js/#{params[:name]}.js"
end

get "/config/*.*" do |file, ext|
  content_type "text/json", :charset => "utf-8"
  puts "#{file}.#{ext}"
  File.read "config/#{file}.#{ext}"
end

map "/search" do
  run Search
end

map "/wsserver" do
  res = catch(:halt) do
    run WsServer
  end
  puts res
end

configure do
  set :DoNotReverseLookup, true
  set :logging, false
  set :default_encoding, "utf-8"
  set :server, :thin

  #  Thread.start {
  #  }

end

#\ --port 64141

run Sinatra::Application
