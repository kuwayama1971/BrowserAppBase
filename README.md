# BrowserAppBase

Windows and Linux browser-based desktop application templates.

On Linux, the Chrome browser is used by default.  
On Windows, the Edge browser is used by default.

---

## Features

- Cross-platform browser-based desktop app template (Windows/Linux)
- Simple app generation command (`create_browser_app`)
- Flexible application settings via `setting.json`
- Communication between browser UI and Ruby backend
- RSpec-based test framework (from v0.1.9)
- Easy browser configuration for each OS

---

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'browser_app_base'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install browser_app_base

---

## Usage

    create_browser_app [options]
     -d, --dir dir_name               application directory
     -a, --app app_name               application name
     -h, --help                       command help

---

## Create app template

    $ create_browser_app -d /path/to/test/ -a MyApp

---

## Add application code

    $ cd /path/to/test/
    $ vi my_app.rb

```ruby
class MyApp < AppMainBase
  def start(argv)
    super
    # add application code
  end

  def stop()
    super
    # add application code
  end
end
```

---

## UI application sample

    index.html
    css/index.css
    js/main.js

---

## Start application

```shell
$ /path/to/test/bin/start_my_app.rb
```

![app](img/app.png)

---

## Browser setting

Configure your browser for Windows or Linux.  

    ${home}/${app_name}/config/browser.json

```json
{
    "chrome_win": "start msedge",
    "chrome_win_": "start chrome",
    "chrome_linux": "/bin/google-chrome"
}
```

---

## Send a message from your browser application to your Ruby application

Use the `send_message` function.

main.js sample:
```javascript
$("#exec").click(function () {
    send_message("exec:" + $("#upFile").val());
});
```

---

## Send a message from the Ruby application to the browser application

Use the `app_send` function.

my_app_sample.rb sample:
```ruby
class MyApp < AppMainBase
  def start(argv)
    # popup message
    app_send("popup:message string")

    # log message
    yield "log message"
  end
end
```

---

## Application Setting

You can add settings by modifying `setting.json`.

    ${home}/${app_name}/config/setting.json

Example (`setting.json`):

```json
{
  "version": 0.1,
  "setting_list": [
    {
      "name": "name1",
      "value": "value1 2 3 4",
      "type": "input",
      "select": "",
      "description": "Setting item 1"
    },
    {
      "name": "name2",
      "value": true,
      "type": "checkbox",
      "select": "",
      "description": "Check to enable"
    },
    {
      "name": "name3",
      "value": "3",
      "type": "select",
      "select": [
        "1",
        "2",
        "3",
        "4",
        "5"
      ],
      "description": "Select item"
    },
    {
      "name": "name4",
      "value": "value4",
      "type": "input",
      "select": "",
      "description": "Setting item 4"
    },
    {
      "name": "name5",
      "value": "value5",
      "type": "input",
      "select": "",
      "description": "Setting item 5"
    },
    {
      "name": "name6",
      "value": "value6",
      "type": "input",
      "select": "",
      "description": "Setting item 6"
    },
    {
      "name": "jaon_area",
      "value": {
        "DEBUG": true,
        "VERSION": 1
      },
      "type": "textarea",
      "select": "",
      "description": "JSON string<br>Example:<br>{<br>  \"DEBUG\": true,<br>  \"VERSION\": 1<br>}"
    }
  ]
}
```

You can access the settings from your Ruby application like this:

```ruby
class MyApp < AppMainBase
  def start(argv)
    # Access a setting value
    puts @config["name1"]
    # Access jaon_area as a hash
    p @config["jaon_area"] # => {"DEBUG"=>true, "VERSION"=>1}
  end
end
```

---

### About `jaon_area` in setting.json

The `jaon_area` item in `setting.json` allows you to input a JSON string as a setting value.  
This field is of type `"textarea"` and is intended for storing flexible, structured data such as additional configuration, flags, or custom parameters.

**Example:**
```json
{
  "DEBUG": true,
  "VERSION": 1
}
```

- You can edit this field directly in the settings screen.
- The value must be valid JSON format.
- The application can parse and use this data as needed.

**Use cases:**
- Toggle debug mode (`"DEBUG": true`)
- Store version or environment information
- Save arbitrary key-value pairs for advanced configuration

**How to use in your Ruby application:**
You can access the `jaon_area` value as a Ruby hash via `@config["jaon_area"]`.  
For example:
```ruby
class MyApp < AppMainBase
  def start(argv)
    debug_mode = @config["jaon_area"]["DEBUG"]
    version = @config["jaon_area"]["VERSION"]
    puts "Debug mode: #{debug_mode}, Version: #{version}"
  end
end
```

**Note:**  
Be sure to enter valid JSON. If the format is incorrect, the application may not be able to read the settings properly.

**Tips:**
- You can use `jaon_area` to store any structured data your application needs at runtime.
- This is useful for feature flags, environment-specific settings, or any advanced configuration that doesn't fit into a simple string or boolean value.

---

## Setting menu  
The following image shows the application's setting menu, where you can access and modify various configuration options.  
![app](img/setting_menu.png)

Setting screen  
This image displays the detailed setting screen, allowing you to edit individual configuration items.  
![app](img/setting.png)

---

## Running Tests

From v0.1.9, RSpec-based testing is supported.  
After installing dependencies, you can run tests with:

```sh
bundle install
bundle exec rake
```

or

```sh
bundle exec rspec
```

RSpec tasks are defined in the `Rakefile`, so `rake` will automatically run all tests.  
Place your test code under the `spec/` directory.

---

## Development

To install this gem onto your local machine, run `bundle exec rake install`.  
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kuwayama1971/BrowserAppBase](https://github.com/kuwayama1971/BrowserAppBase).

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).