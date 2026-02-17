# Devtools Gem - Roadmap

## Current Version: v0.1.0

### What's Included

This initial release includes essential developer tools extracted from a production Rails application:

1. **RuboCop Cop: Rescue Awareness**
   - Location: `lib/rtools/rubocop/cop/custom/awareness_rescue.rb`
   - Enforces documented rescue blocks to prevent careless exception handling
   - Supports inline and line-before awareness comments
   - Includes standalone checker: `Devtools::RescueAwarenessChecker`
   - Executable: `exe/rtools-rescue-awareness`

2. **Performance Profiler Middleware**
   - Location: `lib/rtools/performance_profiler_middleware.rb`
   - Automatic Rails middleware registration via Railtie
   - Profiles request timing, SQL queries, and query details
   - Stores last 5 requests per endpoint in `tmp/performance_profiles`
   - "Invisibility cloak" - exceptions don't show middleware in backtrace
   - Skips assets and static files automatically
   - Configurable via `config.rtools.performance_profiler`

3. **Comprehensive Test Suite**
   - RSpec tests for all components
   - Test coverage for RuboCop cop, middleware, and checker

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'rtools'
```

And then execute:

```bash
$ bundle install
```

### Configuration

#### Performance Profiler

In `config/application.rb`:

```ruby
config.rtools.performance_profiler.enabled = true
config.rtools.performance_profiler.storage_path = 'tmp/performance_profiles'
config.rtools.performance_profiler.skip_paths = ['/assets', '/rails']
```

#### RuboCop Cop

In `.rubocop.yml`:

```yaml
require:
  - rtools

Custom/AwarenessRescue:
  Enabled: true
```

---

## Remaining Tools in Application (Future Extraction Phases)

The following tools remain in the main application and will be extracted in future phases:

### Rake Tasks (Future Phase: Documentation & Changelog Tools)

Location: `lib/tasks/`

1. **apartment.rake** - Multi-tenant database management tasks
2. **changelog.rake** - Changelog generation and management
3. **device_commands.rake** - Device control command utilities
4. **docs.rake** - Documentation screenshot generation
5. **documentation.rake** - Documentation build and packaging
6. **haml.rake** - HAML template conversion tasks
7. **import.rake** - Data import utilities
8. **javascript.rake** - JavaScript build tasks
9. **nats.rake** - NATS messaging system tasks
10. **views.rake** - View template management

### Tenant-Specific Libraries (OUT OF SCOPE - Stay in App)

These are application-specific and should remain in the app:

1. **lib/active_storage/service/tenant_aware_storage_service.rb**
   - Custom ActiveStorage service for multi-tenant file handling
   - Tightly integrated with apartment gem and tenant schema architecture
   - Contains business logic specific to this application's tenancy model

2. **lib/logidze_tenant_support.rb**
   - Logidze audit log extensions for tenant-aware versioning
   - Application-specific audit trail implementation
   - Depends on custom tenant context

### Bin Scripts (Future Phase: Developer Utilities)

Location: `bin/`

1. **parallel_specs** - Parallel test execution wrapper
   - Custom configuration for parallel_tests gem
   - Handles tenant-specific test database setup

2. **bundle**, **rails**, **rake** - Custom wrapper scripts
   - Application-specific environment setup

3. **brakeman** - Security scanner integration

4. **jobs** - Background job management

5. **docker-entrypoint** - Container initialization

6. **thrust** - Thrust RPC framework integration

7. **tapioca**, **tapioca-skip-ssl** - Type generation tools

### Documentation Scripts (Future Phase: Documentation Tools)

These scripts generate and manage project documentation:

1. **bin/generate_changelog_context** - Changelog context generation
2. **bin/generate_docs** - Main documentation generator
3. **bin/pack_docs** - Documentation packaging for deployment
4. **bin/generate_features_doc** - Features documentation
5. **bin/update-deployment-version** - Version tracking

---

## Future Phases

### Phase 4: Documentation & Changelog Tools (Planned)

Extract documentation generation tooling into reusable gem components:

**Components:**
- Documentation screenshot generation framework
- Changelog management system
- Features documentation generator
- Documentation packaging utilities

**Benefits:**
- Reusable documentation workflow for Rails apps
- Standardized screenshot generation for feature specs
- Automated changelog management

**Estimated Complexity:** Medium
**Dependencies:** RSpec, Rails, likely image processing libraries

### Phase 5: Developer Utilities (Planned)

Extract general-purpose developer utilities:

**Components:**
- Parallel specs wrapper with tenant support
- Custom bin scripts for common tasks
- Test database management utilities
- Background job management helpers

**Benefits:**
- Faster test execution in multi-tenant Rails apps
- Standardized development workflows
- Reusable tenant testing patterns

**Estimated Complexity:** High (tenant-specific logic needs abstraction)

---

## Architectural Decisions

### Why Tenant Tools Stay in the App

The tenant-aware libraries (`tenant_aware_storage_service.rb` and `logidze_tenant_support.rb`) are **not** being extracted because:

1. **Business Logic Coupling**: These contain application-specific tenant architecture decisions
2. **Schema Integration**: Deep integration with apartment gem and our custom tenant schema patterns
3. **Domain Knowledge**: Encapsulate multi-tenancy patterns specific to this application's domain
4. **Maintenance Risk**: Extracting would make future tenant architecture changes more difficult

### Why These Tools First (Phase 1-3)

The initial tools were chosen because they are:

1. **Generic**: No application-specific business logic
2. **High Value**: Immediate benefit to any Rails application
3. **Low Coupling**: Minimal dependencies on app architecture
4. **Well Tested**: Already have comprehensive test coverage
5. **Clear Boundaries**: Easy to extract without breaking changes

### Namespace Design

All tools are namespaced under `Devtools` module to:
- Prevent naming conflicts with application code
- Provide clear gem ownership
- Allow for future tool additions without namespace pollution
- Follow Ruby gem conventions

### Versioning Strategy

Starting at v0.1.0 (not v1.0.0) because:
- Initial public release
- API may evolve based on community feedback
- Follows semantic versioning principles for pre-1.0 releases
- Allows for breaking changes while adopting early

---

## Migration Guide

For applications currently using these tools from the main app:

### Step 1: Install the Gem

```ruby
# Gemfile
gem 'rtools', '~> 0.1.0'
```

### Step 2: Update Requires

Remove old requires and add gem requires:

```ruby
# Remove these requires from your codebase:
# require 'rubocop/cop/custom/awareness_rescue'
# require 'dev/performance_profiler_middleware'
# require_relative 'spec/support/rescue_awareness_checker'

# Gem auto-loads via:
# require 'rtools'
```

### Step 3: Update RuboCop Configuration

```yaml
# .rubocop.yml
require:
  - rtools  # Instead of custom path

# Cop is now available as:
# Devtools::RuboCop::Cop::Custom::AwarenessRescue
```

### Step 4: Update Middleware Configuration

No changes needed - Railtie automatically registers middleware in development.

If you had custom middleware configuration:

```ruby
# Remove from config/application.rb or config/environments/development.rb:
# config.middleware.insert_before ActionDispatch::Static, Dev::PerformanceProfilerMiddleware

# Replace with gem configuration:
config.rtools.performance_profiler.enabled = true
```

### Step 5: Update Executable References

```bash
# Old:
bin/rescue_awareness

# New:
exe/rtools-rescue-awareness
# Or if installed via gem:
rtools-rescue-awareness
```

### Step 6: Update Test Helpers

```ruby
# Old:
require 'spec/support/rescue_awareness_checker'

# New (gem auto-loads):
require 'rtools'

RSpec.configure do |config|
  config.before(:suite) do
    Devtools::RescueAwarenessChecker.check_all_files!
  end
end
```

### Step 7: Remove Extracted Files

After confirming everything works:

```bash
# Remove from your app:
rm lib/rubocop/cop/custom/awareness_rescue.rb
rm lib/dev/performance_profiler_middleware.rb
rm bin/rescue_awareness
rm spec/support/rescue_awareness_checker.rb

# Update any remaining references in code
```

### Step 8: Test Thoroughly

- Run full test suite
- Run RuboCop with the new cop
- Test performance profiler in development
- Verify all rescue awareness checks pass

---

## Contributing

Future development will follow this roadmap:

1. Community feedback on v0.1.0
2. Bug fixes and minor improvements
3. Phase 4: Documentation tools
4. Phase 5: Developer utilities
5. Additional tools as requested by community

---

## License

MIT License - See LICENSE.txt for details
