#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

require "bundler/setup"
Bundler.require

require "socket"
require "rack"
require "daemons"
require "fileutils"
require "kconv"
require "json"
require "common"

# ログ出力
module Output
  def self.console_and_file(output_file, stdout = true)
    begin
      defout = File.new(output_file, "a+")
    rescue
      puts $!
      puts $@
      return nil
    end
    class << defout
      alias_method :write_org, :write

      def initialize(stdout)
        @stdout = stdout
      end

      attr_accessor :stdout

      def puts(str)
        STDOUT.write(str.to_s + "\n") if @stdout
        self.write_org(str.to_s + "\n")
        self.flush
      end

      def write(str)
        STDOUT.write(str) if @stdout
        self.write_org(str)
        self.flush
      end
    end
    $stdout = defout
    $stdout.stdout = stdout
  end
end

# ディレクトリ移動
dir = File.dirname(File.expand_path(__FILE__))
FileUtils.cd dir

# ディレクトリ作成
pp ARGV
if ARGV[0] == "test"
  $home_dir = "./"
  ARGV.clear
else
  $home_dir = ENV["HOME"] + "/" + dir.split("/")[-1].gsub(/-[0-9\.-]+/, "") + "/"
end
puts "home_dir=#{$home_dir}"
FileUtils.mkdir_p("#{$home_dir}/logs")
FileUtils.mkdir_p("#{$home_dir}/history")
Output.console_and_file("#{$home_dir}/logs/app.log", true)

# 空きポートを取得（TCPServerを開放することで未使用ポートを確保）
def get_unused_port
  server = TCPServer.new("localhost", 0)
  port = server.addr[1]
  server.close
  return port
end

# ポート番号を書き出し（後続処理用）
port = get_unused_port
puts "port=#{port}"
File.write("config/port.txt", "#{port}\n")

# index.htmlにポート番号を埋め込む（既存の埋め込みを削除してから挿入）
html_buf = File.binread("html/index.html").toutf8
# 既存の <script>\nvar SERVER_PORT=...; </script> を削除
html_buf.gsub!(/<script>\s*\n\s*var SERVER_PORT=\d+;\s*\n\s*<\/script>/, "")

# <head> タグの直後にポート番号スクリプトを挿入（</head> の前に追加）
script_tag = "<script>\nvar SERVER_PORT=#{port};\n</script>"
head_close_pos = html_buf.index("</head>")
if head_close_pos
  # </head> の前に挿入
  pre = html_buf[0...head_close_pos]
  post = html_buf[head_close_pos..-1]
  html_buf = pre + "\n    " + script_tag + "\n" + post
end
File.binwrite("html/index.html", html_buf)

# main.jsのポート番号置換を無効化（動的読み込みに変更）
buf = File.binread("js/main.js").toutf8
File.binwrite("js/main.js", buf)

begin
  # ブラウザ起動スレッド
  browser_thread = Thread.start {
    puts "wait start web server"
    while true
      begin
        s = TCPSocket.open("localhost", port)
        s.close
        break
      rescue
        sleep 0.1
      end
    end

    puts "start browser"
    json_file = "#{$home_dir}/config/browser.json"
    json = JSON.parse(File.read json_file)
    puts json
    kernel = get_os_type
    if kernel.downcase == "windows"
      browser = json["chrome_win"]
    elsif kernel.downcase == "linux"
      browser = json["chrome_linux"]
    else
      browser = json["chrome_win"]
    end
    browser += " -app=http://localhost:#{port}"
    puts browser
    system browser
  }

  # start web server
  require "rackup"
  require "puma"
  Rackup::Server.start(:Port => port, :config => "config.ru")
rescue
  puts $!
  puts $@
  exit
end
