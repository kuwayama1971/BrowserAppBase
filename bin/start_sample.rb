#!/usr/bin/env ruby

require "fileutils"
require "facter"
require "tmpdir"

# tmpdirディレクトリにコピー
dir = File.dirname(File.expand_path(__FILE__ + "/../"))
home_dir = ENV["HOME"] + "/" + dir.split("/")[-1]
puts "home_dir=#{$home_dir}"
Dir.mktmpdir { |tmpdir|
  outdir = tmpdir + "/" + dir.split("/")[-1]
  FileUtils.mkdir_p outdir
  puts outdir
  Dir.glob("#{dir}/lib/*") do |f|
    if f =~ /config$/
      # configはhomeにコピー
      if !File.exists? "#{home_dir}/config"
        puts "#{f} => #{home_dir}/"
        FileUtils.cp_r f, "#{home_dir}/"
      end
    else
      puts "#{f} => #{outdir}/"
      FileUtils.cp_r f, "#{outdir}/"
    end
  end

  FileUtils.cd "#{outdir}"
  kernel = Facter.value(:kernel)
  if kernel == "windows"
    system "rubyw ./start.rb"
  elsif kernel == "Linux"
    system "ruby ./start.rb"
  else
    system "ruby ./start.rb"
  end
  FileUtils.cd ENV["HOME"]
}
