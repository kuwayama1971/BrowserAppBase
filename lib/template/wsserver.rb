$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require "server_app_base"
require "json"
require "cgi"
require "thread"

def config_json_hash(json)
  config = {}
  json["setting_list"].each do |j|
    config[j["name"]] = j["value"]
  end
  return config
end

$ws_exit_thread = nil

class WsServer
  include Singleton
  
  attr_accessor :ws, :exec_thread, :json_config
  attr_reader :lock
  
  def initialize
    @ws = nil
    @ws_lock = Mutex.new
    @json_config = nil
    @exec_thread = nil
  end
  
  def lock
    @ws_lock
  end

  def send_msg(str)
    @ws_lock.synchronize do
      if @ws != nil
        @ws.send(str)
      end
    end
  end
end
