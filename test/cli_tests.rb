require 'assert'

class CLITests < Assert::Context
  desc "CLI"
  setup do
    @cli = CLI.new
  end
  subject { @cli }

  should have_readers :args, :opts
  should have_imeths  :option, :parse!

  def cli_parse(cli, *argv)
    cli.parse! argv
  end

  should "raise `VersionExit` parsing `--version`" do
    assert_raises(CLI::VersionExit) { cli_parse subject, '--version' }
  end

  should "raise `HelpExit` when parsing `--help` and set an opts explanation" do
    exp_msg = "\n        --version\n        --help\n"
    err = begin; cli_parse subject, '--help'; rescue CLI::HelpExit => e; e; end

    assert err
    assert_equal exp_msg, err.message
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
