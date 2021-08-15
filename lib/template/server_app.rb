# -*- coding: utf-8 -*-
class AppMain
  def initialize
    @aboet = false
  end

  def start(file)
    begin
      @abort = false
      puts file
      while true
        yield Time.now.to_s if block_given?
        sleep 1
        break if @abort
      end
    rescue
      puts $!
      puts $@
    end
  end

  def stop()
    @abort = true
  end
end
