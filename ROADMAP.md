# Rtools Gem - Roadmap

## Vision

**Rtools** is a collection of generic, reusable developer tools for Rails applications. The focus is on extracting tools that:

1. Are **generic** - not tied to specific business logic or domain
2. Provide **immediate value** to any Rails application
3. Have **clean boundaries** - minimal dependencies on app architecture
4. Are **well-tested** - comprehensive test coverage

## Current Version: v0.1.0

### What's Included

1. **RuboCop Cop: Rescue Awareness**
   - Location: `lib/rtools/rubocop/cop/custom/awareness_rescue.rb`
   - Enforces documented rescue blocks to prevent careless exception handling
   - Supports inline and line-before awareness comments
   - Includes standalone checker: `Rtools::RescueAwarenessChecker`
   - Executable: `bin/rtools-rescue-awareness`

2. **Performance Profiler**
   - **Middleware:** `lib/rtools/performance_profiler_middleware.rb`
     - Automatic Rails middleware registration via Railtie
     - Profiles request timing, SQL queries, and query details
     - Stores last 5 requests per endpoint in `tmp/performance_profiles`
     - "Invisibility cloak" - exceptions don't show middleware in backtrace
     - Skips assets and static files automatically
     - Configurable via `config.rtools.performance_profiler`
   - **Web UI:** Development-only interface at `/dev/performance_profiles`
     - View all profiles with aggregate statistics
     - Sort by URL, load time, SQL time, request count
     - Visual indicators for slow pages (color-coded)
     - Per-page detail view with individual request profiles
   - **Note:** Controller, views, and services remain in the app (not extracted yet)

### Installation

```ruby
# Gemfile
gem "rtools", github: "RoM4iK/rtools", tag: "v0.1.0"
```

### Configuration

#### Performance Profiler

In `config/application.rb`:

```ruby
config.rtools.performance_profiler.enabled = true
config.rtools.performance_profiler.storage_path = "tmp/performance_profiles"
config.rtools.performance_profiler.skip_paths = ["/assets", "/rails"]
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

## Future Extraction Candidates

### Phase 2: Code Quality Tools (Planned)

Generic tools for improving code quality and maintainability:

#### 1. Orphaned Views Analyzer
- **Location in app:** `lib/tasks/views.rake`
- **Purpose:** Identify views without corresponding controller actions
- **Generic value:** Helps keep codebases clean
- **Complexity:** Medium

### Phase 3: Documentation Tools (Planned)

Tools for generating and managing documentation:

#### 1. Changelog Generator
- **Location in app:** `scripts/generate_changelog_context.rb`, `lib/tasks/changelog.rake`
- **Purpose:** Automated changelog generation from git history
- **Generic value:** Standardized changelog workflow
- **Complexity:** Medium

#### 2. Documentation Screenshot Generator
- **Location in app:** `lib/tasks/docs.rake`, `scripts/generate_docs.js`
- **Purpose:** Automated screenshot generation for feature documentation
- **Generic value:** Useful for any Rails app with feature specs
- **Complexity:** High

### Phase 4: Developer Utilities (Planned)

General-purpose development workflow improvements:

#### 1. Parallel Specs Helper
- **Location in app:** `bin/parallel_specs`
- **Purpose:** Wrapper for parallel_tests with custom configuration
- **Generic value:** Faster test execution
- **Complexity:** Medium (needs abstraction for non-tenant apps)

#### 2. Git Workflow Helpers
- **Location in app:** Various scripts
- **Purpose:** Common git-based development workflows
- **Generic value:** Standardized development processes
- **Complexity:** Low

---

## Out of Scope (Will NOT be Extracted)

The following are **application-specific** and will remain in the main app:

### Tenant-Specific Tools
- `lib/tasks/apartment.rake` - Multi-tenant database management (apartment gem specific)
- `lib/active_storage/service/tenant_aware_storage_service.rb` - Custom tenant-aware storage
- `lib/logidze_tenant_support.rb` - Tenant-specific audit logging

### Business Logic Tools
- `lib/tasks/device_commands.rake` - Hardware-specific device control
- `scripts/copy_bank_logos.rb` - Business-specific asset management
- `scripts/generate_billing_report.rb` - Domain-specific reporting

### Application-Specific Integrations
- `lib/tasks/nats.rake` - App-specific NATS messaging setup
- `lib/tasks/import.rake` - App-specific data import workflows
- `scripts/export_pr.rb` - Custom PR export workflow

### Performance Profiler Web UI
- `app/controllers/dev/performance_profiles_controller.rb` - Web interface for viewing profiles
- `app/views/dev/performance_profiles/` - HTML templates
- `app/services/dev/performance_profile_results_service.rb` - Profile aggregation service
- `app/services/dev/performance_profile_storage_service.rb` - Profile storage service
- **Reason:** The middleware is extracted, but the web UI requires app-specific routing and styling

### Not Needed
- `lib/tasks/haml.rake` - HAML validator (not needed for general use)

---

## Design Principles

### 1. Generic Over App-Specific

Only extract tools that work across different Rails applications without modification. Tools with business logic or domain-specific patterns stay in the app.

### 2. Minimal Dependencies

Prefer tools with few dependencies. Tools requiring complex setup or specific architectural patterns are lower priority.

### 3. Clear Boundaries

Tools should have well-defined interfaces and clear responsibilities. Avoid extracting tightly coupled code.

### 4. Test Coverage

Only extract tools that have comprehensive tests. Tests provide confidence that the extracted code works correctly.

### 5. Namespace Safety

All tools namespaced under `Rtools` module to prevent conflicts with application code.

---

## Migration Guide for v0.1.0

For applications currently using these tools from the main app:

### Step 1: Install the Gem

```ruby
# Gemfile
gem "rtools", github: "RoM4iK/rtools", tag: "v0.1.0"
```

### Step 2: Update RuboCop Configuration

```yaml
# .rubocop.yml
require:
  - rtools  # Instead of custom path

Custom/AwarenessRescue:
  Enabled: true
```

### Step 3: Remove Extracted Files

After confirming everything works:

```bash
# Remove from your app:
rm lib/rubocop/cop/custom/awareness_rescue.rb
rm bin/rescue_awareness
rm spec/lib/devtools/performance_profiler_middleware_spec.rb
```

### Step 4: Test Thoroughly

```bash
bundle install
bundle exec rubocop
# Verify performance profiler works in development
```

---

## Versioning Strategy

- **v0.1.0** - Initial release with rescue awareness and performance profiler middleware
- **v0.2.0** - Planned: Code quality tools (orphaned views analyzer)
- **v0.3.0** - Planned: Documentation tools
- **v1.0.0** - Stable release with comprehensive tooling

Pre-1.0 versions may include breaking changes. Feedback from early adopters will guide API improvements.

---

## Contributing

Future development will be guided by:

1. Community feedback and pull requests
2. Bug fixes and minor improvements
3. Extraction of high-value, generic tools
4. Maintaining backward compatibility when possible

---

## License

MIT License - See LICENSE.txt for details
