require 'open3'
require 'shellwords'

class CLIHarness
  attr_reader :command, :stdin, :argv, :env, :spawn_options

  def self.for(*args)
    new(*args)
  end

  def self.for_commandline(cmdline, **attrs)
    cmd, *argv = Shellwords.split(cmdline)
    new(cmd, attrs.merge(argv: argv))
  end

  def initialize(command, stdin: '', argv: [], env: {}, spawn_options: {}, spawn_in_shell: false)
    @command = command
    @stdin = stdin
    @argv = normalize_argv(argv)
    @env = env
    @spawn_options = spawn_options
    @spawn_in_shell = spawn_in_shell
  end

  def spawn_in_shell?
    @spawn_in_shell
  end

  def with(attr_changes)
    existing_attrs = {
      stdin: stdin,
      argv: argv,
      env: env,
      spawn_options: spawn_options,
      spawn_in_shell: spawn_in_shell?,
    }
    self.class.new(command, existing_attrs.merge(attr_changes))
  end

  def appending_argv(extra_argv)
    with(argv: argv + normalize_argv(extra_argv))
  end

  def merging_env(new_env)
    with(env: env.merge(new_env))
  end

  def run!
    stdout, stderr, status = Open3.capture3(env, *open3_args, **open3_opts)
    Result.new(
      stdout: stdout,
      stderr: stderr,
      status: status,
    )
  end

  def inspect
    "#<#{self.class}: #{commandline}>"
  end

  def commandline
    Shellwords.join([command] + argv)
  end

  private

    def normalize_argv(argv)
      case argv
      when Array then argv #leave it alone
      when String then Shellwords.split(argv) #shell-style args
      else fail("Invalid argv: #{argv.inspect}")
      end
    end

    def open3_args
      if spawn_in_shell?
        # semicolon forces a shell to spawn
        commandline + ' ;'
      else
        # this array form forces there NOT to be a shell according to the docs,
        # and yet a shell is still spawned :/
        [[@command, @command]] + argv
      end
    end

    def open3_opts
      {
        stdin_data: stdin,
      }.merge(spawn_options)
    end

  class Result
    attr_reader :stdout, :stderr, :status

    def initialize(stdout:, stderr:, status:)
      @stdout = stdout
      @stderr = stderr
      @status = status
    end

    def exit_status
      status.exitstatus
    end

    def has_succeeded?
      exit_status == 0
    end

    def has_failed?
      !has_succeeded?
    end
  end

end
