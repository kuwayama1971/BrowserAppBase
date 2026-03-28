# -*- coding: utf-8 -*-
require "json"

class AppMainBase
  def initialize
    @config = nil
    @abort = false
    @exec = false
    @suspend = false
    @ws = nil
  end

  def app_send(str)
    @ws&.send(str)
  end

  def set_ws(ws)
    @ws = ws
  end

  def set_config(config)
    @config = config
  end

  def start(argv)
    @exec = true
  end

  def stop
    @abort = true
    @exec = false
  end

  def suspend
    @suspend = true
  end

  def resume
    @suspend = false
  end

  # 履歴の保存
  def add_history(file, history_data, max = 10)
    home_dir = @config&.key?(:home_dir) ? @config[:home_dir] : ($home_dir || "./")
    history_dir = home_dir + "history/"
    path = File.join(history_dir, file)
    begin
      buf = File.read(path)
      data = JSON.parse(buf)
    rescue
      data = []
    end
    if history_data.to_s != ""
      data.unshift(history_data)
    end
    data = data.uniq[0, max]
    File.write(path, JSON.pretty_generate(data))
  end
end

require_relative "app_load"
