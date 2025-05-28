# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Ruby-based automation system that implements scheduled use cases following a standardized pipeline pattern.

### Common Use Case Pipeline
Most use cases follow this pattern:
1. **Fetch** - Extract data from external sources (APIs, Notion, GitHub, IMAP, etc.)
2. **Format** - Transform and process the fetched data
3. **Notify** - Send processed data to destinations (Discord, WhatsApp, external storage, etc.)
4. **Garbage Collect** - Archive processed records

### Directory Structure
- `src/implementations/` - Reusable bot implementations that inherit from `Bas::Bot::Base`
- `src/use_cases_execution/[use_case]/` - Use case orchestration files that wire implementations together
- `src/use_cases_execution/schedules.rb` - Centralized scheduling configuration
- `spec/implementations/` - Tests mirroring the implementation structure

### Shared Storage Pattern
All use cases use `Bas::SharedStorage` with PostgreSQL as the coordination layer:
- Each pipeline step reads from and writes to the database with specific tags
- Tags track processing stages: `FetchX`, `FormatX`, `NotifyX`, `GarbageCollector`
- Steps execute in sequence based on the scheduling system using `src/use_cases_execution/schedules.rb`

### Scheduling System
The orchestrator (`scripts/execute_orchestrator.rb`) loads schedules from `schedules.rb` and executes them using the BAS framework. Schedules support:
- `time: ['HH:MM']` - Specific execution times
- `day: ['Monday']` - Specific days of the week
- `interval: milliseconds` - Interval-based execution

### Adding New Use Cases
When the user asks to implement a new use case, follow these rules:

**Interactive Mode:**
- Before starting to code a new use case, ask the user relevant questions about data sources, outputs, and requirements

**Non-Interactive Mode:**
- Make reasonable assumptions for unspecified details, but clearly communicate these assumptions to the user
- Add relevant comments so the user knows what to change and why
- If the description is too vague or lacks sufficient detail to proceed with implementation, stop and:
  - List the specific details you need
  - Provide feedback to help the user write better prompts

**General Guidelines:**
- Add relevant documentation comments to explain how users can use and understand the code
- Follow good code practices, including:
  - Adding an empty line at the end of files
  - Clear variable naming
  - Proper error handling

#### Technical Constraints
- Use HTTParty for HTTP requests
- This is not a Rails project - use explicit imports for modules (e.g., `Date`, `DateTime`)
- Follow Ruby conventions and best practices

#### Before Starting
- Review existing implementations to gain context on how things are done.
- Unless specified by the user, choose a descriptive name for the new use case (referenced as `[name]` in the steps below)
- If the user doesn't specify a schedule, use a time-based schedule starting at noon

#### Implementation Steps
Follow this process to add a new use case:
1. Create implementations in `src/implementations/` (if they don't already exist)
2. Create use case directory in `src/use_cases_execution/[name]/` with `config.rb` and 4 pipeline files
3. Add schedule constants to `schedules.rb`
4. Update database schema in `db/build_shared_storage.sql` if needed
5. Write comprehensive tests in `spec/implementations/[name]/`

### Executing Individual Files
Prefix `bundle exec` to any `ruby` command to ensure execution within the project's context:
```ruby
bundle exec ruby src/use_cases_execution/irl_reminders/notify_on_discord.rb
```

### Configuration
- Environment variables via `env.yml` (copy from `env.yml.example`)
- Database connection configuration standardized across all use cases in each `config.rb`
- BAS framework handles orchestration and shared storage coordination
