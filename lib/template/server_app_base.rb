# -*- coding: utf-8 -*-
class AppMainBase
  def initialize
    @config = nil
    @aboet = false
    @exec = false
    @suspend = false
  end

  def set_config(config)
    @config = config
  end

  def start(argv)
    @exec = true
  end

  def stop()
    @abort = true
    @exec = false
  end

  def suspend()
    @suspend = true
  end

  def resume()
    @suspend = false
  end
end

require "app_load.rb"
