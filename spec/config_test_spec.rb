require "rack/test"
require "rspec"

RSpec.describe "Sinatra Application (config.ru)" do
  include Rack::Test::Methods

  def app
    # config.ruをRack::Builderでパースしてアプリとして返す
    # Rack 3 ではRack::Builder.parse_fileがアプリを直接返す
    app_from_config = Rack::Builder.parse_file(File.expand_path("../lib/template/config.ru", __dir__))
    inner_app = app_from_config.is_a?(Array) ? app_from_config.first : app_from_config
    inner_app
  end

  before(:each) do
    # For Rack 3 / Sinatra, we must bypass HostAuthorization in Rack::Test
    ENV['RACK_ENV'] = 'test'
  end


  before(:all) do
    Dir.chdir("lib/template/")

    # Set up dummy $home_dir for testing
    $home_dir = Dir.mktmpdir
    FileUtils.mkdir_p("#{$home_dir}/logs")
    FileUtils.mkdir_p("#{$home_dir}/config")
    FileUtils.mkdir_p("#{$home_dir}/history")
    # テスト用のファイルを作成
    File.write("#{$home_dir}/logs/sinatra.log", "")
    #File.write(File.expand_path("html/index.html", __dir__), "INDEX")
    File.write(File.expand_path("../lib/template/css/test.css", __dir__), "body { color: red; }")
    File.write(File.expand_path("../lib/template/js/test.js", __dir__), "console.log('test');")
    File.write("#{$home_dir}/config/test.json", '{"test":1}')
    File.write("#{$home_dir}/history/test.json", '["foo","bar","baz"]')
  end

  after(:all) do
    FileUtils.rm_rf($home_dir)
    #FileUtils.rm_f(File.expand_path("html/index.html", __dir__))
    FileUtils.rm_f(File.expand_path("../lib/template/css/test.css", __dir__))
    FileUtils.rm_f(File.expand_path("../lib/template/js/test.js", __dir__))
  end

  it "serves the index.html at /" do
    get "/"
    expect(last_response).to be_ok
    expect(last_response.body).to include("html")
  end

  it "serves css files at /css/:name.css" do
    get "/css/test.css"
    expect(last_response).to be_ok
    expect(last_response.body).to include("color: red")
    expect(last_response.content_type).to include("text/css")
  end

  it "serves js files at /js/:name.js" do
    get "/js/test.js"
    expect(last_response).to be_ok
    expect(last_response.body).to include("console.log")
    expect(last_response.content_type).to include("text/javascript")
  end

  it "serves config files at /config/*.*" do
    get "/config/test.json"
    expect(last_response).to be_ok
    expect(last_response.body).to include("1")
    expect(last_response.content_type).to include("text/json").or include("application/json")
  end

  it "serves history files at /history/*.* with POST" do
    post "/history/test.json", param1: ""
    expect(last_response).to be_ok
    expect(last_response.body).to include("foo")
    expect(last_response.body).to include("bar")
    expect(last_response.body).to include("baz")
  end

  it "filters history files at /history/*.* with POST and param1" do
    post "/history/test.json", param1: "ba"
    expect(last_response).to be_ok
    expect(last_response.body).to include("bar")
    expect(last_response.body).to include("baz")
    expect(last_response.body).not_to include("foo")
  end

  it "serves open_dialog with message" do
    get "/open_dialog", msg: "Hello"
    expect(last_response).to be_ok
    expect(last_response.body).to include("Hello")
    expect(last_response.body).to include("<html>")
  end

  it "maps /search to Search app" do
    get "/search", path: "/", kind: "file"
    expect(last_response).to be_ok
    expect(last_response.content_type).to include("application/json")
  end

  it "maps /wsserver to WsServer app" do
    # WebSocket handshake is not supported by Rack::Test, but we can check the route exists
    get "/wsserver"
    expect([200, 400, 426, 500]).to include(last_response.status)
  end
end
