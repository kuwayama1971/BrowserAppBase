#!/usr/bin/env ruby

require "fileutils"
require "facter"
require "tmpdir"

# tmpdirディレクトリにコピー
dir = File.dirname(File.expand_path(__FILE__)) + "/../"
Dir.mktmpdir { |tmpdir|
  puts tmpdir
  Dir.glob("#{dir}/lib/*") do |f|
    puts "#{f} => #{tmpdir}"
    FileUtils.cp_r f, "#{tmpdir}"
  end

  FileUtils.cd "#{tmpdir}"
  kernel = Facter.value(:kernel)
  if kernel == "windows"
    system "rubyw ./start.rb"
  elsif kernel == "Linux"
    system "ruby ./start.rb"
  else
    system "ruby ./start.rb"
  end
}
