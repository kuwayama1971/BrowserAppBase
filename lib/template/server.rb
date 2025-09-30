require "sinatra"
require "sinatra/contrib"
require "sinatra-websocket"
require "thin"
require "json"
require "kconv"
require "cgi"
require "pathname"
require "facter"

class Search < Sinatra::Base
  helpers Sinatra::Streaming
  get "/" do
    content_type "application/json", :charset => "utf-8"
    q_hash = {}
    puts request.query_string
    request.query_string.split("&").each do |q|
      work = q.split("=")
      if work[1] != nil
        q_hash[work[0]] = CGI.unescape(work[1].toutf8)
      else
        q_hash[work[0]] = ""
      end
    end
    begin
      str = q_hash["path"].gsub(/\\/, "/")
    rescue
      str = "/"
    end
    puts "str=#{str}"
    str = "/" if str.to_s == ""
    kind = q_hash["kind"].gsub(/\\/, "/")
    puts "kind=#{kind}"
    kind = "file" if kind.to_s == ""
    res = []
    str = str.gsub(/\\/, "/")
    dir = File.dirname(str)
    file = File.basename(str)
    puts "dir=#{dir}"
    puts "file=#{file}"

    kernel = Facter.value(:kernel)
    if kernel.downcase == "windows"
      dir = "c:/" if dir.nil? || dir == "/"
    elsif kernel.downcase == "linux"
      dir = "/" if dir.nil?
    else
      dir = "c:/" if dir.nil? || dir == "/"
    end

    path = "#{dir}/#{file}"
    if File.directory?(path)
      path = path + "/*"
    else
      path = path + "*"
    end
    path.gsub!(/[\/]+/, "/")
    puts path
    Dir.glob(path, File::FNM_DOTMATCH).each do |file|
      data = {}
      next if File.basename(file) == "."
      next if kind == "dir" and !File.directory?(file)
      data["label"] = File.basename(file)
      data["label"] += "/" if File.directory?(file)
      data["value"] = File.expand_path(file)
      res.push data
    end
    if 0 == res.select { |dir| dir["label"] == "../" }.size
      data = {}
      pp = Pathname(File.expand_path("#{dir}/#{file}"))
      data["label"] = "../"
      data["label"] += "/" if pp.parent.to_s == "/"
      data["value"] = pp.parent.to_s
      data["value"] = "/" if data["value"] =~ /^[\/]+$/
      res.push data
    end
    JSON.generate res.sort { |a, b| a["value"] <=> b["value"] }
  end
end
