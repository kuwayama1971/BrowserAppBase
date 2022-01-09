#!/usr/bin/env ruby

require "fileutils"

# ディレクトリ移動
dir = File.dirname(File.expand_path(__FILE__))
FileUtils.cd "#{dir}/../lib/template"
system "ruby ./start.rb &"
