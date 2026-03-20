# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

mongoid-fixture_kit is a Ruby gem that provides ActiveRecord-style test fixtures for Mongoid (MongoDB ODM). It loads YAML fixture files into MongoDB for testing, supporting `belongs_to`, `has_many`, `has_and_belongs_to_many`, polymorphic relations, and embedded documents.

## Commands

- **Run all tests:** `bundle exec rake test`
- **Run a single test file:** `bundle exec ruby -Ilib:test test/mongoid/fixture_kit_test.rb`
- **Run a single test by name:** `bundle exec ruby -Ilib:test test/mongoid/fixture_kit_test.rb -n test_should_create_fixtures`
- **Lint:** `bundle exec rubocop`
- **Build gem:** `bundle exec rake build`
- **Release gem:** `bundle exec rake release`

## Prerequisites

Tests require a running MongoDB instance on `localhost:27017`. See `test/mongoid.yml` for connection config. The test database (`mongoid_fixture_kit_test`) is dropped after each test in `BaseTest#teardown`.

## Architecture

### Core loading pipeline

1. **`TestHelper`** (`lib/mongoid/fixture_kit/test_helper.rb`) — Module included in test classes. Manages fixture lifecycle (`setup_fixtures`/`teardown_fixtures`), generates accessor methods (e.g., `users(:geoffroy)`), and handles caching.

2. **`Util`** (`lib/mongoid/fixture_kit/util.rb`) — The engine that creates fixtures. `create_fixtures` reads YAML files, resolves all relation types (belongs_to, has_many, HABTM, embedded), and persists documents to MongoDB. This is the most complex file — relation unmarshalling happens here.

3. **`FixtureKit`** (`lib/mongoid/fixture_kit.rb`) — Represents a single fixture set (one YAML file). Reads YAML files via `File`, creates `Fixture` objects.

4. **`Fixture`** (`lib/mongoid/fixture_kit/fixture.rb`) — Represents a single fixture entry. Provides `find` to query MongoDB by `__fixture_name`.

5. **`File`** (`lib/mongoid/fixture_kit/file.rb`) — Handles YAML parsing with ERB support.

### Key concepts

- Documents are stored with a `__fixture_name` attribute used for lookups and relation resolution.
- Relation resolution in `Util#unmarshall_fixture` converts fixture names in YAML to actual document references (ObjectIds).
- Embedded documents are handled separately from top-level documents — `extract_embedded_attributes` / `apply_embedded_attributes` in Util work around Mongoid 8+ bracket notation behavior.
- `ClassCache` resolves fixture set names to Mongoid model classes.

### Test structure

- Tests use Minitest (not RSpec) with `ActiveSupport::TestCase`.
- `BaseTest` in `test/test_helper.rb` drops the test database after each test.
- Fixture YAML files are in `test/fixtures/` and relation-specific fixture dirs (e.g., `test/nested_polymorphic_relation_fixtures/`).
- Test models are in `test/models/`.

## Branching

- `master` is the release branch
- `develop` is the main development branch; PRs target `master`

## Commit Conventions

Use Conventional Commits format:

- `feat:` — new feature (minor version bump)
- `fix:` — bug fix (patch version bump)
- `docs:` — documentation changes
- `test:` — test additions/changes
- `chore:` — maintenance, CI, dependencies

Example: `feat: add support for embeds_many relations`

## Release Flow

1. Development happens on `develop` with Conventional Commit messages
2. `/release` skill merges develop → master, creates tag, pushes
3. Tag push triggers `gem-publish.yml` which publishes to RubyGems and creates a GitHub Release with auto-generated notes
