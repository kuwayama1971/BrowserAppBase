#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require "socket"
require "rack"
require "daemons"
require "fileutils"
require "kconv"
require "json"
require "facter"

# ログ出力
module Output
  def self.console_and_file(output_file)
    defout = File.new(output_file, "a+")
    class << defout
      alias_method :write_org, :write

      def puts(str)
        STDOUT.write(str.to_s + "\n")
        self.write_org(str.to_s + "\n")
        self.flush
      end

      def write(str)
        STDOUT.write(str)
        self.write_org(str)
        self.flush
      end
    end
    $stdout = defout
  end
end

Output.console_and_file("log.txt")

# ディレクトリ移動
dir = File.dirname(File.expand_path(__FILE__))
FileUtils.cd dir

# 空きポートを取得
def get_unused_port
  s = TCPServer.open(0)
  port = s.addr[1]
  s.close
  return port
end

# 空きポートを取得
port = get_unused_port
puts "port=#{port}"

# config.ruの編集
buf = File.binread("config.ru").toutf8
buf.gsub!(/port [0-9]+/, "port #{port}")
File.binwrite("config.ru", buf)

# main.jsの編集
buf = File.binread("js/main.js").toutf8
buf.gsub!(/localhost:[0-9]+\//, "localhost:#{port}/")
File.binwrite("js/main.js", buf)

# index.htaの編集
buf = File.binread("index.html").toutf8
buf.gsub!(/localhost:[0-9]+\//, "localhost:#{port}/")
File.binwrite("index.html", buf)

begin
  Thread.start {
    puts "wait start web server"
    while true
      begin
        s = TCPSocket.open("localhost", port)
        s.close
        break
      rescue
        puts $!
        sleep 0.1
      end
    end

    puts "start browser"
    json_file = File.dirname(File.expand_path(__FILE__)) + "/config/browser.json"
    json = JSON.parse(File.read json_file)
    puts json
    kernel = Facter.value(:kernel)
    if kernel == "windows"
      browser = json["chrome_win"]
    elsif kernel == "Linux"
      browser = json["chrome_linux"]
    else
      browser = json["chrome_win"]
    end
    browser += " -app=http://localhost:#{port}"
    puts browser
    system browser
  }

  # start web server
  Rack::Server.start
rescue
  puts $!
  puts $@
  exit
end
