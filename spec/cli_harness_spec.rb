RSpec.describe CLIHarness do
  context '#run!' do
    subject { CLIHarness.for_command('cat', stdin: 'meow', argv: argv).run! }

    context 'success' do
      let(:argv) { '-' }

      it { is_expected.to have_succeeded }
      it { is_expected.not_to have_failed }
      its(:exit_status) { is_expected.to eq(0) }
      its(:stdout) { is_expected.to eq('meow') }
      its(:stderr) { is_expected.to eq('') }
    end

    context 'failure' do
      let(:argv) { 'some_non_existant_file.25235235235.whatever' }

      it { is_expected.to have_failed }
      it { is_expected.not_to have_succeeded }
      its(:exit_status) { is_expected.to be > 0 }
      its(:stdout) { is_expected.to eq('') }
      its(:stderr) { is_expected.to include('some_non_existant_file') }
    end
  end

  context '#argv' do
    it 'is empty by default' do
      expect(CLIHarness.new('whatever').argv).to eq([])
    end

    it 'allows shell-style strings' do
      harness1 = CLIHarness.new('whatever', argv: '--a b')
      harness2 = harness1.with(argv: 'c d')
      harness3 = harness1.appending_argv('e f')

      expect(harness1.argv).to eq(['--a', 'b'])
      expect(harness2.argv).to eq(['c', 'd'])
      expect(harness3.argv).to eq(['--a', 'b', 'e', 'f'])
    end

    it 'allows arrays' do
      harness1 = CLIHarness.new('whatever', argv: ['--a', 'b'])
      harness2 = harness1.with(argv: ['c', 'd'])
      harness3 = harness1.appending_argv(['e', 'f'])

      expect(harness1.argv).to eq(['--a', 'b'])
      expect(harness2.argv).to eq(['c', 'd'])
      expect(harness3.argv).to eq(['--a', 'b', 'e', 'f'])
    end
  end

  context '#env' do
    it 'is empty by default' do
      expect(CLIHarness.new('whatever').env).to eq({})
    end

    it 'can be set via the constructor, and changed via #with' do
      harness1 = CLIHarness.new('whatever', env: { a: 1 })
      harness2 = harness1.with(env: { b: 2 })
      expect(harness1.env).to eq({ a: 1 })
      expect(harness2.env).to eq({ b: 2 })
    end

    it 'can be merged' do
      harness1 = CLIHarness.new('whatever', env: { a: 1, b: 2 })
      harness2 = harness1.merging_env({ b: 33, c: 44 })
      expect(harness2.env).to eq({ a: 1, b: 33, c: 44 })
    end

    it 'is passed to the spawning method' do
      result = CLIHarness.for_command('env')
        .with(env: { 'MOOMOOFARM' => '5' })
        .run!

      expect(result.stdout).to include('MOOMOOFARM')
    end
  end

  context '#spawn_options' do
    it 'is empty by default' do
      expect(CLIHarness.new('whatever').spawn_options).to eq({})
    end

    it 'can be changed via #with' do
      harness1 = CLIHarness.new('whatever', spawn_options: { hello: 3 })
      harness2 = harness1.with(spawn_options: { bye: 5 })
      expect(harness2.spawn_options).to eq({ bye: 5 })
    end

    it 'is passed to the spawning method' do
      harness = CLIHarness.for_command('pwd', spawn_options: { chdir: '/usr' })
      expect(harness.run!.stdout.strip).to eq('/usr')
    end
  end

  context '#spawn_in_shell?' do
    it 'is false by default' do
      expect(CLIHarness.new('whatever').spawn_in_shell?).to be(false)
    end

    it 'can be set via the constructor, and changed via #with' do
      harness1 = CLIHarness.new('whatever', spawn_in_shell: false)
      harness2 = harness1.with(spawn_in_shell: true)
      expect(harness1.spawn_in_shell?).to eq(false)
      expect(harness2.spawn_in_shell?).to eq(true)
    end

    it 'affects how the command is spawned' do
      harness = CLIHarness.for_commandline('env')

      in_shell = harness.with(spawn_in_shell: true).run!
      without_shell = harness.with(spawn_in_shell: false).run!

      expect(in_shell.stdout).not_to eq(without_shell.stdout)
    end
  end
end
