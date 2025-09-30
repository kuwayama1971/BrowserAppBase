# filepath: /home/kuwayama/tool/github/BrowserAppBase/lib/template/server_test.rb
require "rack/test"
require "rspec"
require_relative "../lib/template/server"

RSpec.describe Search do
  include Rack::Test::Methods

  def app
    Search.new
  end

  before do
    allow(Facter).to receive(:value).with(:kernel).and_return("Linux")
  end

  context "GET / with kind=file" do
    it "returns JSON with files in the directory" do
      Dir.mktmpdir do |tmpdir|
        File.write("#{tmpdir}/foo.txt", "bar")
        File.write("#{tmpdir}/baz.txt", "baz")
        get "", { path: tmpdir, kind: "file" }
        expect(last_response).to be_ok
        json = JSON.parse(last_response.body)
        labels = json.map { |e| e["label"] }
        expect(labels).to include("foo.txt", "baz.txt", "../")
      end
    end
  end

  context "GET / with kind=dir" do
    it "returns JSON with directories only" do
      Dir.mktmpdir do |tmpdir|
        FileUtils.mkdir_p("#{tmpdir}/dir1")
        FileUtils.mkdir_p("#{tmpdir}/dir2")
        File.write("#{tmpdir}/file.txt", "bar")
        get "", { path: tmpdir, kind: "dir" }
        expect(last_response).to be_ok
        json = JSON.parse(last_response.body)
        dir_labels = json.map { |e| e["label"] }
        expect(dir_labels).to include("dir1/", "dir2/", "../")
        expect(dir_labels).not_to include("file.txt")
      end
    end
  end

  context "GET / with missing path" do
    it "handles missing path gracefully" do
      get "", { kind: "file" }
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json).to be_a(Array)
    end
  end

  context "GET / with Windows kernel" do
    it "uses c:/ as root if dir is nil or /" do
      allow(Facter).to receive(:value).with(:kernel).and_return("Windows")
      get "", { path: "/", kind: "file" }
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json).to be_a(Array)
    end
  end

  context "GET / with Linux kernel" do
    it "uses / as root if dir is nil" do
      allow(Facter).to receive(:value).with(:kernel).and_return("Linux")
      get "", { path: "", kind: "file" }
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json).to be_a(Array)
    end
  end
end