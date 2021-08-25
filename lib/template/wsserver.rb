require "./server_app_base"

class WsServer < Sinatra::Base
  $ws_list = []
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
