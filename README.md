# Rtools

A collection of reusable developer tools for Rails applications, extracted from production experience.

## Features

### 🔍 Rescue Awareness Cop

A custom RuboCop cop that enforces documented rescue blocks to prevent careless exception handling.

**Why it matters:**
- Prevents silent failures that hide bugs
- Forces intentional exception handling
- Discourages AI-generated careless rescue blocks
- Makes code review more effective

**Usage:**

```ruby
# ❌ Bad - No awareness comment
def process_data
  parse_json(data)
rescue JSON::ParserError
  nil
end

# ✅ Good - Documented intent
def process_data
  parse_json(data)
rescue JSON::ParserError # awareness rescue: invalid JSON returns nil for backward compatibility
  nil
end
```

### 📊 Performance Profiler Middleware

Development-only middleware that profiles request performance, SQL queries, and timing data.

**Features:**
- Automatic profiling in development (configurable)
- Tracks request timing, SQL count, and SQL timing
- Stores last 5 requests per endpoint
- "Invisibility cloak" - exceptions don't show middleware in backtrace
- Skips assets and static files automatically

**Output:** Stored in `tmp/performance_profiles/*.json`

```json
[
  {
    "url": "/users",
    "method": "GET",
    "total_time": 125.5,
    "sql_time": 45.2,
    "sql_queries": [
      {
        "sql": "SELECT * FROM users",
        "duration": 12.3
      }
    ],
    "timestamp": "2024-01-24T12:00:00.000Z",
    "request_id": "abc-123"
  }
]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rtools"
```

And then execute:

```bash
$ bundle install
```

## Configuration

### Performance Profiler

In `config/application.rb`:

```ruby
config.rtools.performance_profiler.enabled = true
config.rtools.performance_profiler.storage_path = "tmp/performance_profiles"
config.rtools.performance_profiler.skip_paths = ["/assets", "/rails"]
```

**Default behavior:**
- Only runs in `development` environment
- Stores profiles in `tmp/performance_profiles`
- Skips `/assets`, `/rails/active_storage`, and static file paths
- Keeps last 5 requests per endpoint

### RuboCop Cop

In `.rubocop.yml`:

```yaml
require:
  - rtools

Custom/AwarenessRescue:
  Enabled: true

# You can also exclude specific files or directories
Custom/AwarenessRescue:
  Enabled: true
  Exclude:
    - 'db/schema.rb'
    - 'vendor/bundle/**/*'
```

### Rescue Awareness Checker

Use the standalone checker in your test suite or CI:

```ruby
# spec/spec_helper.rb
require "rtools"

RSpec.configure do |config|
  config.before(:suite) do
    Rtools::RescueAwarenessChecker.check_all_files!
  end
end
```

Or run via executable:

```bash
# Check all files in app/
bin/rtools-rescue-awareness

# Check specific directories
bin/rtools-rescue-awareness app lib
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

### Testing

Run the test suite:

```bash
bundle exec rspec
```

### Building the Gem

```bash
gem build rtools.gemspec
gem install rtools-0.1.0.gem
```

## Roadmap

See [ROADMAP.md](ROADMAP.md) for:
- Current version contents
- Future extraction phases
- Tools remaining in the main app
- Migration guide

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RoM4iK/rtools.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
