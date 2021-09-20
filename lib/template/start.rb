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

Thread.start {
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

Rack::Server.start
