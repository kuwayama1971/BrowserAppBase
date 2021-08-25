#!/usr/bin/env ruby

require "bundler/setup"
require "browser_app_base"
require "optparse"

opt = OptionParser.new
o = {}
opt.on("-d dir_name", "--dir dir_name", "application directory") { |v| o[:dir] = v }
opt.on("-a app_name", "--app app_name", "application name") { |v| o[:app] = v }
opt.on("-h", "--help", "command help") { puts opt; exit }
begin
  opt.parse!(ARGV)
rescue
  puts opt
  exit
end

if o[:dir] == nil
  puts opt
  exit
end

BrowserAppBase.create o
