# frozen_string_literal: true

# 1. require in the cli.rb code (or paste it as MyCLI child class or something)

require "mycli/cli"

# 2. setup your CLI class, have it compose CLIRB (or sub-class or whatever)

class MyCLI
  def initialize
    @cli =
      CLIRB.new do
        option(
          :method,
          "method: line, word (default), or char",
          value: String,
        )
        option(
          :format,
          "format: ascii (default), color, html, or esc",
          value: String,
        )
        option(:ascii, "format output in ascii")
        option(:color, "format output in color")
        option(:html,  "format output in html")
        option(:esc,   "format output as escaped-html w/ color")
      end
  end

  def run(*args)
    begin
      @cli.parse!(*args)

      # 3. inspect, validate, handle the opts and args

      a  = @cli.args
      aa = a.map(&:inspect).join(", ")
      raise CLIRB::Error, "too few arguments (#{a.size}): #{aa}"  if a.size < 2
      raise CLIRB::Error, "too many arguments (#{a.size}): #{aa}" if a.size > 2

      @cli.opts[:method] ||= "word"
      @cli.opts[:format] ||= "ascii" if @cli.opts[:ascii]
      @cli.opts[:format] ||= "color" if @cli.opts[:color]
      @cli.opts[:format] ||= "html"  if @cli.opts[:html]
      @cli.opts[:format] ||= "ascii"

      begin

        # 4. Use CLIRB data in a handler or whatever

        MyHandler.new(*@cli.data).run
      rescue MyError => ex
        raise CLIRB::Error, ex.message
      end

    # 5. Use the CLIRB exceptions to handle different usage cases

    rescue CLIRB::HelpExit
      puts help_msg
      exit(0)
    rescue CLIRB::VersionExit
      puts MyCLI::VERSION
      exit(0)
    rescue CLIRB::Error => ex
      puts "#{ex.message}\n\n"
      puts help_msg
      exit(1)
    rescue => ex
      puts "#{ex.message}\n\n"
      exit(1)
    end
  end

  def help_msg
    "Usage: mycli [opts] LEFT RIGHT\n"\
    "#{@cli}"
  end
end
