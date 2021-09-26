require "./server_app_base"
require "json"
require "cgi"

def config_json_hash(json)
  config = {}
  json.each do |j|
    config[j["name"]] = j["value"]
  end
  return config
end

class WsServer < Sinatra::Base
  $ws_list = []
  json_config = nil
  exec_thread = nil
  get "" do
    if !request.websocket?
      "no supported"
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("startup:#{$startup_file}")
          $ws_list << ws
        end
        ws.onmessage do |msg|
          puts msg
          if msg =~ /^exec:/
            if exec_thread == nil
              json = JSON.parse(File.read("config/setting.json"))
              json_config = config_json_hash(json)
              $app.set_config(json_config)
              argv = msg.gsub(/^exec:/, "")
              exec_thread = Thread.new {
                begin
                  $app.start(argv.split(",")) do |out|
                    ws.send(out)
                  end
                  ws.send("app_end:normal")
                rescue
                  puts $!
                  puts $@
                  puts "app_end:err"
                  ws.send("app_end:error")
                ensure
                  puts "exit thread"
                  exec_thread = nil
                end
              }
            else
              puts "app_end:err"
              ws.send("app_end:error")
            end
          end
          if msg =~ /^stop/
            if exec_thread
              $app.stop
            end
          end
          if msg =~ /^suspend/
            if exec_thread
              $app.suspend
            end
          end
          if msg =~ /^resume/
            if exec_thread
              $app.resume
            end
          end
          if msg =~ /^setting:/
            json_string = msg.gsub(/^setting:/, "")
            json = JSON.parse(json_string)
            File.open("config/setting.json", "w") do |w|
              w.puts JSON.pretty_generate(json)
            end
            json_config = config_json_hash(json)
            $app.set_config(json_config)
          end
          if msg =~ /^openfile:/
            file = msg.gsub(/^openfile:/, "")
            Thread.new {
              system "#{json_config["editor"]} #{CGI.unescapeHTML(file)}"
            }
          end

          if msg == "exit"
            unless ENV["OCRA"] == "true"
              halt
              #exit
            end
          end
        end
        ws.onclose do
          puts "websocket closed"
          $ws_list.delete(ws)
          puts $ws_list.size
          if $ws_list.size == 0
            puts ENV["OCRA"]
            unless ENV["OCRA"] == "true"
              #halt
              exit
            end
          end
        end
      end
    end
  end
end
