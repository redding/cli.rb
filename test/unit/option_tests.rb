# frozen_string_literal: true

require "assert"
require "cli"

class CLIRB::Option
  class UnitTests < Assert::Context
    desc "CLIRB::Option"
    setup do
      @option = CLIRB::Option.new("test", "testing", value: "value")
    end
    subject{ @option }

    should have_readers :name, :opt_name, :desc, :abbrev, :value
    should have_readers :klass, :parser_args

    should "know its name and desc" do
      assert_equal "test", subject.name
      assert_equal "testing", subject.desc
    end

    should "know its value and klass" do
      assert_equal "value", subject.value
      assert_equal String,  subject.klass
    end

    should "know its defaults" do
      opt_with_defaults = CLIRB::Option.new(:test)
      assert_equal :test,    opt_with_defaults.name
      assert_equal "",       opt_with_defaults.desc
      assert_equal nil,      opt_with_defaults.value
      assert_equal NilClass, opt_with_defaults.klass
    end

    should "always use the given name as the option name" do
      assert_equal :Test, CLIRB::Option.new(:Test).name
    end

    should "parse its opt_name from the name" do
      assert_equal "test",        CLIRB::Option.new("test").opt_name
      assert_equal "testit",      CLIRB::Option.new("TestIt").opt_name
      assert_equal "test-it",     CLIRB::Option.new("test_it").opt_name
      assert_equal "test-it",     CLIRB::Option.new("Test_it").opt_name
      assert_equal "test-it-now", CLIRB::Option.new("test_it-now").opt_name
    end

    should "parse its opt_abbrev from the first letter of the opt_name" do
      assert_equal "t", CLIRB::Option.new("test").abbrev
      assert_equal "i", CLIRB::Option.new("it-test").abbrev
      assert_equal "t", CLIRB::Option.new("123test").abbrev
      assert_equal "t", CLIRB::Option.new("_test").abbrev
      assert_equal "a", CLIRB::Option.new("1234").abbrev
    end

    should "override its opt_abbrev with the :abbrev setting" do
      assert_equal "x", CLIRB::Option.new("test", "", abbrev: "x").abbrev
    end

    should "set its value to `nil` if given a Class :value" do
      opt = CLIRB::Option.new("test", "", value: String)
      assert_nil opt.value
      assert_equal String, opt.klass
    end
  end

  class SwitchOptTests < UnitTests
    desc "that is a switch"
    setup do
      @option = CLIRB::Option.new("test", "testing")
    end

    should "use its opt_abbrev, opt_name, and desc in the parser_args" do
      exp_args = ["-t", "--[no-]test", "testing"]
      assert_equal exp_args, subject.parser_args
    end
  end

  class ValueOptTests < UnitTests
    desc "that is not a switch"
    setup do
      @option = CLIRB::Option.new("thing", "testing", value: "value")
    end

    should "use abbrev, name with VALUE, klass, and desc in the parser_args" do
      exp_args = ["-t", "--thing VALUE", String, "testing"]
      assert_equal exp_args, subject.parser_args
    end
  end
end
