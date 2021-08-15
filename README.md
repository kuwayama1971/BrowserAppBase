# BrowserAppBase

Windows and Linux browser-based desktop application templates.

You need a Chrome browser to run it.

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

    create_browser_app [options]
     -d, --dir dir_name               application directory
     -h, --help                       command help


create app templat

    $ create_browser_app -d ~/test/

start application

    $ cd ~/test/app
    $ ruby start.rb

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kuwayama1971/BrowserAppBase.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
