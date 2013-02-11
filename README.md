# cli.rb

A command-line argument parser for Ruby.

## Usage

```ruby
require 'cli'

cli = CLI.new do
  option :severity, "set severity", :value => 4
  option :verbose, "enable verbose output"
  option :thing, "set thing", :value => String
end

cli.parse! ['--verbose', 'some', 'other', 'args']
cli.opts  #=> {:severity => 4, :verbose => true, :thing => nil}
cli.args  #=> ["some", "other", "args", {:severity => 4, :verbose => true, :thing => nil}]
```

## Features

There is no install, no dependency to manage.  Just copy in `cli.rb` (<60 loc) to your project and use it.

It does no validations or handling.  It only parses the options and builds an arguments list.  It raises exceptions on errors.  You define your own handling.

## Notes

* You must define :value, if the option should accept an argument. Every option without a :value is treated as a switch.
* To define long arguments with spaces and other special characters, define an option which takes a `String` as an argument. Everything between quotes will be parsed as the value for that argument.
* To define arguments which accept lists, define an option which takes an `Array` as an argument.  The input will be split by comma. If the arguments contain spaces, wrap the whole thing in quotes.

## Installation

Copy the `cli.rb` file into your project and require it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
