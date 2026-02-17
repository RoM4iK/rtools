# frozen_string_literal: true

require_relative "lib/rtools/version"

Gem::Specification.new do |spec|
  spec.name = "rtools"
  spec.version = Rtools::VERSION
  spec.authors = ["Tinker Agent"]
  spec.email = ["tinker-agent@tinkerai.win"]

  spec.summary = "Custom developer tooling for Rails applications"
  spec.description = "A collection of reusable developer tools including RuboCop cops, performance profiling middleware, and other utilities for Rails applications."
  spec.homepage = "https://github.com/RoM4iK/rtools"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RoM4iK/rtools/tree/main/lib/rtools"
  spec.metadata["changelog_uri"] = "https://github.com/RoM4iK/rtools/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob("lib/rtools/**/*") +
               Dir.glob("sig/**/*") +
               Dir.glob("exe/*") +
               %w[README.md LICENSE.txt CHANGELOG.md lib/rtools.rb]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies - use pessimistic version constraint for better stability
  spec.add_dependency "rubocop", "~> 1.0"
  spec.add_dependency "rails", "~> 6.0"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
