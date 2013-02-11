# 1. require in the cli.rb code (you code also paste it as child class or something)

require 'cli'

# 2. setup your CLI class, have it compose ::CLI (or sub-class or whatever)

class MyCLI
  def initialize
    @cli = ::CLI.new do
      option :method, "method: line, word (default), or char", {
        :value => String
      }
      option :format, "format: ascii (default), color, html, or esc", {
        :value => String
      }
      option :ascii, "format output in ascii"
      option :color, "format output in color"
      option :html,  "format output in html"
      option :esc,   "format output as escaped-html w/ color"
    end
  end

  def run(*args)
    begin
      @cli.parse!(*args)

# 3. inspect, validate, handle the opts and args

      a = @cli.args; aa = a.map(&:inspect).join(', ')
      raise ::CLI::Error, "too few arguments (#{a.size}): #{aa}"  if a.size < 2
      raise ::CLI::Error, "too many arguments (#{a.size}): #{aa}" if a.size > 2

      @cli.opts['method'] ||= 'word'
      @cli.opts['format'] ||= 'ascii' if @cli.opts['ascii']
      @cli.opts['format'] ||= 'color' if @cli.opts['color']
      @cli.opts['format'] ||= 'html'  if @cli.opts['html']
      @cli.opts['format'] ||= 'ascii'

      begin

# 4. Use the CLI data in a handler or whatever

        MyHandler.new(*@cli.data).run
      rescue MyError => err
        raise ::CLI::Error, err.message
      end

# 5. Use the CLI exceptions to handle different usage cases

    rescue ::CLI::HelpExit
      puts help_msg
      exit(0)
    rescue ::CLI::VersionExit
      puts MyCLI::VERSION
      exit(0)
    rescue ::CLI::Error => err
      puts "#{err.message}\n\n"
      puts help_msg
      exit(1)
    rescue Exception => err
      puts "#{err.message}\n\n"
      exit(1)
    end
  end

  def help_msg
    "Usage: mycli [opts] LEFT RIGHT\n"\
    "#{@cli}"
  end

end
