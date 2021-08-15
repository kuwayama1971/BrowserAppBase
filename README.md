# BrowserAppBase

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/browser_app_base`. To experiment with that code, run `bin/console` for an interactive prompt.

Windows and Linux browser-based desktop application templates

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'browser_app_base'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install browser_app_base

## Usage

Usage: create_browser_app [options]
    -d, --dir dir_name               application directory
    -h, --help                       command help

$ create_browser_app -d ~/test/
$ cd ~/test/app
$ ruby start.rb

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kuwayama1971/BrowserAppBase.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
