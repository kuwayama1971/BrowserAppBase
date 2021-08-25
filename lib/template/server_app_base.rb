# -*- coding: utf-8 -*-
class AppMainBase
  def initialize
    @aboet = false
    @exec = false
    @suspend = false
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
