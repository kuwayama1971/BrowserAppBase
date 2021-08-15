# frozen_string_literal: true

require_relative "browser_app_base/version"

require "fileutils"

module BrowserAppBase
  class Error < StandardError; end

  # Your code goes here...

  def self.create(dir)
    puts "create application base #{dir}"

    FileUtils.mkdir_p dir

    path = File.dirname(File.expand_path(__FILE__))
    FileUtils.cp_r "#{path}/template", "#{dir}/app"
  end
end
