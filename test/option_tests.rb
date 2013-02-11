require 'assert'

class OptionTests < Assert::Context
  desc "an Option"
  setup do
    @option = CLI::Option.new('test', "testing", :value => 'value')
  end
  subject{ @option }

  should have_readers :name, :opt_name, :desc, :abbrev, :value, :klass, :parser_args

  should "know its name and desc" do
    assert_equal 'test', subject.name
    assert_equal 'testing', subject.desc
  end

  should "know its value and klass" do
    assert_equal 'value', subject.value
    assert_equal String,  subject.klass
  end

  should "know its defaults" do
    opt_with_defaults = CLI::Option.new(:test)
    assert_equal '',       opt_with_defaults.desc
    assert_equal nil,      opt_with_defaults.value
    assert_equal NilClass, opt_with_defaults.klass
  end

  should "force its name to a downcased string val" do
    assert_equal 'test', CLI::Option.new(:Test).name
  end

  should "parse its opt_name from the name" do
    assert_equal 'test',        CLI::Option.new('test').opt_name
    assert_equal 'testit',      CLI::Option.new('TestIt').opt_name
    assert_equal 'test-it',     CLI::Option.new('test_it').opt_name
    assert_equal 'test-it',     CLI::Option.new('Test_it').opt_name
    assert_equal 'test-it-now', CLI::Option.new('test_it-now').opt_name
  end

  should "parse its opt_abbrev from the first letter of the opt_name" do
    assert_equal 't', CLI::Option.new('test').abbrev
    assert_equal 'i', CLI::Option.new('it-test').abbrev
    assert_equal 't', CLI::Option.new('123test').abbrev
    assert_equal 't', CLI::Option.new('_test').abbrev
    assert_equal 'a', CLI::Option.new('1234').abbrev
  end

  should "override its opt_abbrev with the :abbrev setting" do
    assert_equal 'x', CLI::Option.new('test', '', :abbrev => 'x').abbrev
  end

  should "set its value to `nil` if given a Class :value" do
    opt = CLI::Option.new('test', '', :value => String)
    assert_nil opt.value
    assert_equal String, opt.klass
  end

  should "set the klass to Integer if given a Fixnum" do
    assert_equal Integer, CLI::Option.new('test', '', :value => 1).klass
    assert_equal Integer, CLI::Option.new('test', '', :value => Fixnum).klass
  end

end

class SwitchOptTests < OptionTests
  desc "that is a switch"
  setup do
    @option = CLI::Option.new('test', "testing")
  end

  should "use its opt_abbrev, opt_name, and desc in the parser_args" do
    exp_args = ['-t', '--[no-]test', 'testing']
    assert_equal exp_args, subject.parser_args
  end

end

class ValueOptTests < OptionTests
  desc "that is not a switch"
  setup do
    @option = CLI::Option.new('thing', "testing", :value => 'value')
  end

  should "use abbrev, name with VALUE, klass, and desc in the parser_args" do
    exp_args = ['-t', '--thing THING', String, 'testing']
    assert_equal exp_args, subject.parser_args
  end

end
