# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Documentation and changelog tools (Phase 4)
- Developer utilities (Phase 5)

## [0.1.0] - 2024-01-24

### Added
- **RuboCop Cop: Rescue Awareness**
  - Custom cop that enforces documented rescue blocks
  - Supports inline and line-before awareness comments
  - Helps prevent careless exception handling
  - Location: `lib/rtools/rubocop/cop/custom/awareness_rescue.rb`

- **Rescue Awareness Checker**
  - Standalone checker module for validating rescue blocks
  - Can be used in test suites or CI/CD pipelines
  - Provides detailed violation reports with file paths and line numbers
  - Location: `lib/rtools/rescue_awareness_checker.rb`

- **Executable: rtools-rescue-awareness**
  - Command-line tool for running rescue awareness checks
  - Supports checking multiple directories
  - Location: `exe/rtools-rescue-awareness`

- **Performance Profiler Middleware**
  - Development-only request profiling middleware
  - Tracks request timing, SQL queries, and SQL timing
  - Stores last 5 requests per endpoint in JSON format
  - "Invisibility cloak" hides middleware from exception backtraces
  - Automatically skips assets and static files
  - Configurable via Rails configuration
  - Location: `lib/rtools/performance_profiler_middleware.rb`

- **Railtie for Automatic Integration**
  - Automatically registers middleware in Rails applications
  - Provides configuration namespace: `config.rtools.performance_profiler`
  - Location: `lib/rtools/railtie.rb`

- **Comprehensive Test Suite**
  - RSpec tests for all components
  - Tests for RuboCop cop functionality
  - Tests for performance profiler middleware
  - Tests for rescue awareness checker

- **Documentation**
  - Detailed README with usage examples
  - ROADMAP.md outlining current and future phases
  - Migration guide for applications adopting the gem
  - Architectural decisions documentation

### Dependencies
- rubocop >= 1.0
- rails >= 6.0
- Ruby >= 3.0.0

### Development Dependencies
- rake ~> 13.0
- rspec ~> 3.0

## [0.0.1] - 2024-01-24

### Added
- Initial gem scaffold
- Gem specification and configuration

[Unreleased]: https://github.com/tinkerai/rtools/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/tinkerai/rtools/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/tinkerai/rtools/releases/tag/v0.0.1
