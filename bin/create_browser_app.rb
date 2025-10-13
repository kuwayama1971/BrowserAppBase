#!/usr/bin/env ruby

require "bundler/setup"
require "browser_app_base"
require "optparse"

opt = OptionParser.new
o = {}
opt.on("-d DIR_NAME", "--dir DIR_NAME", "application directory") { |v| o[:dir] = v }
opt.on("-a APP_NAME", "--app APP_NAME", "application name") { |v| o[:app] = v }
opt.on("-h", "--help", "command help") { puts opt; exit }
begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts opt
  exit
end

if o[:dir].nil? || o[:dir].strip.empty?
  puts opt
  exit
end

BrowserAppBase.create o