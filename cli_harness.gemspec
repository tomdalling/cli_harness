# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cli_harness/version"

Gem::Specification.new do |spec|
  spec.name          = "cli_harness"
  spec.version       = CliHarness::VERSION
  spec.authors       = ["Tom Dalling"]
  spec.email         = ["tom" + "@" + "tomdalling.com"]

  spec.summary       = %q{Wrapper/harness for executing CLI programs and capturing output}
  spec.homepage      = "https://github.com/tomdalling/cli_harness"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  #spec.bindir        = "exe"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "byebug"
end
