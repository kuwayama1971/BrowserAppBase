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

  def self.get_app_name(app)
    app_name = ""
    app.each_char do |s|
      if s =~ /[a-z]/ and app_name.size == 0
        app_name += s.upcase
      else
        app_name += s
      end
    end
    return app_name
  end

  def self.create(arg)
    dir = arg[:dir]
    app = arg[:app]
    puts "create application base #{dir}"

    FileUtils.mkdir_p dir
    FileUtils.mkdir_p dir + "/lib/"
    FileUtils.mkdir_p dir + "/bin/"

    path = File.dirname(File.expand_path(__FILE__)) + "/../"
    Dir.glob("#{path}/lib/template/*") do |f|
      puts "#{f} => #{dir}/lib"
      FileUtils.cp_r f, "#{dir}/lib"
    end

    if app
      app_file = get_app_file(app)

      puts "#{path}/bin/start_sample.rb #{dir}/bin/start_#{app_file}"
      FileUtils.cp_r "#{path}/bin/start_sample.rb", "#{dir}/bin/start_#{app_file}"

      load_app = <<"EOS"
require '#{app_file}'
$app = #{get_app_name(app)}.new
EOS

      File.open("#{dir}/lib/app_load.rb", "w") do |f|
        f.write load_app
      end

      puts "create #{app_file}"
      new_file = "#{dir}/lib/#{app_file}"
      FileUtils.cp("#{dir}/lib/my_app_sample.rb", new_file)
      buf = File.binread(new_file)
      File.binwrite(new_file, buf.gsub(/MyApp/, get_app_name(app)))
    end
  end
end
