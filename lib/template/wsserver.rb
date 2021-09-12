require "./server_app_base"
require "json"

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
            json = JSON.parse(File.read("config/setting.json"))
            json_config = config_json_hash(json)
            $app.set_config(json_config)
            argv = msg.gsub(/^exec:/, "")
            Thread.new {
              $app.start(argv.split(",")) do |out|
                ws.send(out)
              end
            }
          end
          if msg =~ /^stop/
            $app.stop
          end
          if msg =~ /^suspend/
            $app.suspend
          end
          if msg =~ /^resume/
            $app.resume
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
