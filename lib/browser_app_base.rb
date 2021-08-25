# frozen_string_literal: true

require_relative "browser_app_base/version"
require "fileutils"

module BrowserAppBase
  class Error < StandardError; end

  def self.get_app_file(app)
    app_file_name = ""
    app.each_char do |s|
      if s =~ /[A-Z]/
        app_file_name += "_" if app_file_name.size != 0
        app_file_name += s.downcase
      else
        app_file_name += s
      end
    end
    return app_file_name + ".rb"
  end

  def self.create(arg)
    dir = arg[:dir]
    app = arg[:app]
    puts "create application base #{dir}"

    FileUtils.mkdir_p dir

    path = File.dirname(File.expand_path(__FILE__))
    Dir.glob("#{path}/template/*") do |f|
      puts "#{f} => #{dir}"
      FileUtils.cp_r f, "#{dir}/"
    end

    if app
      app_file = get_app_file(app)

      load_app = <<"EOS"
      require '#{app_file}'
      $app = MyApp.new
EOS

      File.open("#{dir}/app_load.rb", "w") do |f|
        f.write load_app
      end

      puts "create #{app_file}"
      FileUtils.cp "#{dir}/my_app_sample.rb", "#{dir}/#{app_file}"
    end
  end
end
