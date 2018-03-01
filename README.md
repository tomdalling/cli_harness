# CLIHarness

A harness/wrapper class for executing CLI programs, and capturing the output.

This was originally created to assist the testing of CLI apps.


## Usage Examples

```ruby
require 'cli_harness'

harness = CLIHarness.for_commandline('echo cat dog rat')
harness.command #=> "echo"
harness.argv #=> ["cat"]

result = harness.run!
result.stdout      #=> "cat dog rat"
result.stderr      #=> ""
result.exit_status #=> 0
result.has_succeeded?  #=> true
result.has_failed?     #=> false
```

```ruby
require 'cli_harness'

RSpec.describe "my CLI app" do
  let(:cli) { CLIHarness.for('bin/my_app') }

  context 'with --a flag' do
    subject { cli.with(argv: '--a whatever').run! }

    it { is_expected.to have_succeeded }
    its(:stdout) { is_expected.to include('<<whatever output here>>') }
  end

  context 'on failure' do
    subject { cli.with(argv: 'badarg').run! }

    its(:exit_status) { is_expected.to eq 127 }
    its(:stderr) { is_expected.to include('badarg is not a valid arg') }
  end
end
```
