# frozen_string_literal: true

require_relative "lib/browser_app_base/version"

Gem::Specification.new do |spec|
  spec.name = "browser_app_base"
  spec.version = BrowserAppBase::VERSION
  spec.authors = ["masataka kuwayama"]
  spec.email = ["masataka.kuwayama@gmail.com"]

  spec.summary = "browser app base"
  spec.description = "browser application template"
  spec.homepage = "https://github.com/kuwayama1971/BrowserAppBase"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  #spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = spec.homepage
  #spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "bin"
  #spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "sinatra"
  spec.add_dependency "sinatra-contrib"
  spec.add_dependency "sinatra-websocket"
  spec.add_dependency "thin"
  spec.add_dependency "json"
  spec.add_dependency "facter"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
