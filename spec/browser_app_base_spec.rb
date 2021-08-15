# frozen_string_literal: true

RSpec.describe BrowserAppBase do
  it "has a version number" do
    expect(BrowserAppBase::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
