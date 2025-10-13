# -*- coding: utf-8 -*-
$LOAD_PATH << File.dirname(File.expand_path(__FILE__))

# get os type
def get_os_type
  if RUBY_PLATFORM =~ /win32|mingw|cygwin/
    "windows"
  elsif RUBY_PLATFORM =~ /linux/
    "linux"
  else
    "unknown"
  end
end
