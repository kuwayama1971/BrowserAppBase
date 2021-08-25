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

#\ --port 61611

run Sinatra::Application
