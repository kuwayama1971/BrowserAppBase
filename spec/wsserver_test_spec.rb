require "rack/test"
require "rspec"
require "json"
require "fileutils"
require "sinatra"
require "sinatra/contrib"
require "sinatra-websocket"
require "thin"
require "json"

require_relative "../lib/template/wsserver"

RSpec.describe WsServer do
  include Rack::Test::Methods

  #let(:app) { WsServer.new }
  let(:app) { WsServer.allocate.tap { |a| a.send(:initialize) } }

  describe "#config_json_hash" do
    it "converts setting_list to a hash" do
      json = {
        "setting_list" => [
          { "name" => "foo", "value" => "bar" },
          { "name" => "baz", "value" => "qux" },
        ],
      }
      expect(config_json_hash(json)).to eq({ "foo" => "bar", "baz" => "qux" })
    end
  end

  describe "#ws_send" do
    it "sends message to first ws in list" do
      ws = double("ws")
      expect(ws).to receive(:send).with("hello")
      app.instance_variable_set(:@ws_list, [ws])
      app.ws_send("hello")
    end

    it "does nothing if ws_list is empty" do
      app.instance_variable_set(:@ws_list, [])
      expect { app.ws_send("test") }.not_to raise_error
    end
  end

  # WebSocket通信のテストはRack::Testでは困難なため、ここではルーティングの基本動作のみ確認
  describe "GET ''" do
    it "returns 'no supported' if not websocket" do
      get "/", {}, { "PATH_INFO" => "" }
      expect(last_response.body).to include("no supported")
    end
  end
end
