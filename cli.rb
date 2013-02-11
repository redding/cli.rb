class CLI  # Version 0.0.1, https://github.com/redding/cli.rb
  OptsParseError = Class.new(RuntimeError)
  attr_reader :argv, :args, :opts

  def initialize(&block)
    @options = []; instance_eval(&block) if block
    require 'optparse'
    @args, @opts = [], {}; @parser = OptionParser.new do |p|
      p.banner = ''; @options.each do |o|
        @opts[o.name] = o.default; p.on(*o.parser_args){ |v| @opts[o.name] = v }
      end
      a = @options.map(&:abbrev).include?('v') ? 'V' : 'v'
      p.on_tail("-#{a}", "--version", ''){ |v| throw 'version', v }
      p.on_tail("-h", "--help", ''){ |v| throw 'help', @parser.to_s.strip }
    end
  end

  def parse!(argv)
    @args = (argv || []).dup.tap do |args_list|
      begin; @parser.parse!(args_list)
      rescue OptionParser::ParseError => err; raise OptsParseError, err.message; end
    end; @args << @opts
  end
  def option(*args); @options << Option.new(*args); end
  def inspect
    "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @args=#{@args.inspect}>"
  end

  class Option
    attr_reader :name, :opt_name, :desc, :abbrev, :default, :klass, :parser_args

    def initialize(name, *args)
      settings, @desc = args.last.kind_of?(::Hash) ? args.pop : {}, args.pop || ''
      @name, @opt_name, @abbrev = parse_name_values(name, settings[:abbrev])
      @default, @klass = get_default_settings(settings)
      @parser_args = if [TrueClass, FalseClass].include?(@klass)
        ["-#{@abbrev}", "--[no-]#{@opt_name}", @desc]
      else
        ["-#{@abbrev}", "--#{@opt_name} #{@default}", @klass, @desc]
      end
    end

    private

    def parse_name_values(name, custom_abbrev)
      [ (processed_name = name.to_s.strip.downcase), processed_name.gsub('_', '-'),
        custom_abbrev || processed_name.gsub(/[^a-z]/, '').chars.first || 'a'
      ]
    end
    def get_default_settings(settings)
      [ (val = settings[:default] || false), val.class == Fixnum ? Integer : val.class ]
    end
  end
end
