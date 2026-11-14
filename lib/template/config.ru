# -*- coding: utf-8 -*-
require "sinatra"
require "sinatra/contrib"
require "json"

require "./server"
require "./wsserver"

BASE_DIR = File.dirname(File.expand_path(__FILE__))

def config_json_hash(json)
  config = {}
  json["setting_list"].each do |j|
    config[j["name"]] = j["value"]
  end
  return config
end

class App < Sinatra::Base
  configure do
    set :DoNotReverseLookup, true
    set :logging, true
    set :default_encoding, "utf-8"
    set :server, :puma
    
    log_path = "#{$home_dir}/logs/sinatra.log" if $home_dir
    use Rack::CommonLogger, log_path ? File.new(log_path, "a+") : STDOUT
  end

  get "/" do
    logger.info "BASE_DIR=#{BASE_DIR}"
    File.read("#{BASE_DIR}/html/index.html")
  end

  get "*.html" do |file|
    content_type "text/html", :charset => "utf-8"
    File.read "#{BASE_DIR}//html/#{file}.html"
  end

  get "/css/:name.css" do
    content_type "text/css", :charset => "utf-8"
    logger.info "#{BASE_DIR}/css/#{params[:name]}.css"
    File.read "#{BASE_DIR}/css/#{params[:name]}.css"
  end

  get "/js/:name.js" do
    content_type "text/javascript", :charset => "utf-8"
    logger.info "#{BASE_DIR}/js/#{params[:name]}.js"
    File.read "#{BASE_DIR}/js/#{params[:name]}.js"
  end

  get "/config/*.*" do |file, ext|
    content_type "text/json", :charset => "utf-8"
    logger.info "#{file}.#{ext}"
    File.read "#{$home_dir}/config/#{file}.#{ext}"
  end

  post "/history/*.*" do |file, ext|
    content_type "text/json", :charset => "utf-8"
    logger.info "#{file}.#{ext}"
    p = params[:param1]
    begin
      buf = File.read "#{$home_dir}/history/#{file}.#{ext}"
    rescue
      buf = ""
    end
    data = eval(buf)
    if data != nil
      if p != ""
        JSON.generate data.find_all { |d| d =~ Regexp.new(p) }
      else
        JSON.generate data
      end
    end
  end

  get "/open_dialog" do
    dialog_html = <<'EOS'
  <!DOCTYPE html>
  <html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Message Dialog</title>
    <style type="text/css">
    <!--
    body {
      color: #000000;
      background-color: #ffffff;
      overflow: hidden;
      font-size: 12px;
    }
    -->    
    </style>
    </head>
EOS
    dialog_html += "<body>" + params["msg"] + "</body></html>"
  end
  
  get "/wsserver" do
    if Faye::WebSocket.websocket?(request.env)
      ws = Faye::WebSocket.new(request.env, nil, {ping: 0})

      ws.on :open do |event|
        logger.info "ws.open"
        WsServer.instance.lock.synchronize do
          WsServer.instance.ws = ws
          $app.set_ws(ws)
          pp "ws=#{ws}"
        end
        WsServer.instance.send_msg("startup:#{$startup_file}")
        logger.info "ws_exit_thread=#{$ws_exit_thread}"
        if $ws_exit_thread != nil
          logger.info "ws_exit_thread kill"
          Thread.kill $ws_exit_thread
          $ws_exit_thread = nil
        end
      end

      ws.on :message do |event|
        msg = event.data
        logger.info msg
        begin
          json = JSON.parse(File.read("#{$home_dir}/config/setting.json"))
          @json_config = config_json_hash(json)
          $app.set_config(@json_config)
        rescue
          logger.info "Failed to load config/setting.json"
          @json_config = {}
        end

        if msg =~ /^exec:/
          if WsServer.instance.exec_thread == nil
            argv = msg.gsub(/^exec:/, "")
            WsServer.instance.exec_thread = Thread.new {
              begin
                $app.start(argv.split(",")) do |out|
                  WsServer.instance.send_msg(out)
                end
                WsServer.instance.send_msg("app_end:normal")
              rescue
                logger.info $!
                logger.info "app_end:err"
                WsServer.instance.send_msg("app_end:error")
              ensure
                logger.info "exit thread"
                WsServer.instance.exec_thread = nil
              end
            }
          else
            logger.info "app_end:err"
            WsServer.instance.send_msg("app_end:error")
          end
        end
        if msg =~ /^stop/
          if WsServer.instance.exec_thread
            Thread.kill WsServer.instance.exec_thread
            WsServer.instance.send_msg("app_end:stop")
            $app.stop
            WsServer.instance.exec_thread = nil
          end
        end
        if msg =~ /^suspend/
          if WsServer.instance.exec_thread
            $app.suspend
          end
        end
        if msg =~ /^resume/
          if WsServer.instance.exec_thread
            $app.resume
          end
        end
        if msg =~ /^setting:/
          json_string = msg.gsub(/^setting:/, "")
          begin
            json = JSON.parse(json_string)
            File.open("#{$home_dir}/config/setting.json", "w") do |w|
              w.puts JSON.pretty_generate(json)
            end
            WsServer.instance.json_config = config_json_hash(json)
            $app.set_config(WsServer.instance.json_config)
          rescue
            # jsonファイルではない
            WsServer.instance.send_msg("app_end:error")
          end
        end
        if msg =~ /^openfile:/
          file = msg.gsub(/^openfile:/, "")
          Thread.new {
            if WsServer.instance.json_config && WsServer.instance.json_config["editor"]
              system "#{WsServer.instance.json_config["editor"]} #{CGI.unescapeHTML(file)}"
            else
              logger.info "Editor not set in config"
            end
          }
        end

        # アプリケーション終了
        if msg == "exit"
          exit
        end
      end

      ws.on :close do |event|
        logger.info "websocket closed"
        WsServer.instance.lock.synchronize do
          WsServer.instance.ws = nil
        end
        $ws_exit_thread = Thread.start {
          sleep 1
          exit
        }
        logger.info "ws_exit_thread=#{$ws_exit_thread}"
      end

      return ws.rack_response
    else
      halt 200, {"Content-Type" => "text/plain"}, ["no supported"]
    end
  end
  
  # /search は Search クラスに委譲（map は config.ru レベルで処理）
end

map "/search" do
  run Search
end

run App
