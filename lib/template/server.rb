require 'json'
require 'kconv'

class Search < Sinatra::Base
  helpers Sinatra::Streaming
  get '' do
    q_hash = {}
    puts request.query_string
    request.query_string.split("&").each do |q|
      work = q.split("=")
      if work[1] != nil
        q_hash[work[0]] = CGI.unescape work[1].toutf8
      else
        q_hash[work[0]] = ""
      end
    end
    str = q_hash["path"].gsub(/\\/,"/")
    puts "str=#{str}"
    res = []
    str = str.gsub(/\\/, "/")
    dir = File.dirname(str)
    dir = "c:/" if dir == nil
    file = File.basename(str)
    file = "/" if file == nil
    path = "#{dir}/#{file}"
    if File.exists?(path)
      path = path + "/*"
    else
      path = path + "*"
    end
    puts path
    Dir.glob(path).each do |file|
      data = {}
      data["label"] = File.basename(file)
      data["value"] = file 
      res.push data
    end
    JSON.generate res
  end
end
