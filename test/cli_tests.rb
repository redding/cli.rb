require 'assert'

class CLITests < Assert::Context
  desc "CLI"
  setup do
    @cli = CLI.new
  end
  subject { @cli }

  should have_imeths :option, :to_s, :parse!
  should have_readers :args, :opts

  def catch_thrown(cli, thrown, *argv)
    catch(thrown){ cli.parse! argv }
  end

  should "operate on ARGV by default" do
    assert_equal [], ARGV
    subject.parse!
    assert_empty subject.args
    assert_empty subject.opts
  end

end

class VersionTests < CLITests

  should "catch `version` when parsing `-v` when with no other 'v' opts" do
    val = catch_thrown CLI.new, 'version', '-v'
    assert_equal true, val
  end

  should "catch `version` when parsing `-V` when with other 'v' opts" do
    cli = CLI.new{ option 'verbose', 'verbosity'}
    val = catch_thrown cli, 'version', '-V'
    assert_equal true, val

    cli = CLI.new{ option 'anopt', 'opt', :abbrev => 'v' }
    val = catch_thrown cli, 'version', '-V'
    assert_equal true, val
  end

end

class HelpTests < CLITests

  should "catch `help` when parsing `-h`" do
    assert_nothing_raised { catch_thrown CLI.new, 'help', '-h' }
  end

  should "return an opts explanation message when catching `help`" do
    exp_msg = "-v, --version\n    -h, --help"
    val = catch_thrown CLI.new, 'help', '-h'
    assert_equal exp_msg, val
  end

end

class SwitchTests < CLITests
  desc "when parsing a switch opt"
  setup do
    @cli = CLI.new{ option 'verbose', 'verbosity'}
  end

  should "default to false" do
    subject.parse! []
    assert_equal false, subject.opts['verbose']
  end

  should "set true if abbrev" do
    subject.parse! ['-v']
    assert_equal true, subject.opts['verbose']
  end

  should "set true if full" do
    subject.parse! ['--verbose']
    assert_equal true, subject.opts['verbose']
  end

  should "set false if full negative" do
    subject.parse! ['--no-verbose']
    assert_equal false, subject.opts['verbose']
  end

end

class SingleValueTests < CLITests
  desc "when parsing a single value opt"
  setup do
    @cli = CLI.new{ option 'skill', 'skillz', :default => '' }
  end

  should "set the default" do
    subject.parse! []
    assert_equal '', subject.opts['skill']
  end

  should "set the value if abbrev" do
    subject.parse! ['-s', 'booyah']
    assert_equal 'booyah', subject.opts['skill']
  end

  should "set the value if full" do
    subject.parse! ['--skill', 'booyah']
    assert_equal 'booyah', subject.opts['skill']
  end

  should "type-cast the value" do
    cli = CLI.new{ option 'skill', 'skillz', :default => 1 }
    cli.parse! ['-s', '12']
    assert_equal 12, cli.opts['skill']
  end

end

class ListValueTests < CLITests
  desc "when parsing a list value opt"
  setup do
    @cli = CLI.new{ option 'skill', 'skillz', :default => [] }
  end

  should "set the list values by parsing the value as comma-separated" do
    subject.parse! ['--skill', 'art,deco,eat,sleep']
    assert_equal ['art', 'deco', 'eat', 'sleep'], subject.opts['skill']
  end

end
