# Improvement Plan

Rounds 1 and 2 completed (37 items). See git history for details.

## Round 3 — Code Quality

1. **`find_or_create_document` silently returns unsaved document on error** — downstream code uses `.id` creating dangling foreign keys (util.rb:149-163)
2. **`collection_documents` mutates fixture_kit's fixtures hash** — `fixtures.delete('DEFAULTS')` should use `reject` or `dup` (util.rb:173)

## Round 3 — Build

1. **Remove unused `pry-nav` dependency** — no file requires it after Round 1 cleanup (Gemfile:13)
2. **Add `changelog_uri` to gemspec** — point to GitHub Releases page
3. ~~**`sonar-project.properties` version hardcoded** — removed property~~ DONE

## Round 3 — CI/CD

1. **Ruby 3.1 is EOL** (since 2025-03-31) — drop from CI matrix, bump gemspec to `>= 3.2.0`
2. **`test.sh` lacks `set -e`** — rubocop failures don't stop execution; script is redundant with CI
3. ~~**gem-publish writes credentials to disk** — switched to `GEM_HOST_API_KEY` env var~~ DONE

## Round 3 — Tests

1. **Test coverage gaps** — uncovered paths: `teardown_fixtures`, `fixtures(:all)`, `sanitize_new_embedded_documents` belongs_to branch, `embedded_document_set_default_values` removable fields, error branch in `find_or_create_document`

## Round 3 — Docs and Config

1. ~~**SimpleCov only outputs JSON** — added `MultiFormatter` with HTML + JSON~~ DONE
2. **LICENSE copyright year** — says 2023, should be `2023-2026`
3. **`File.open` naming is misleading** — nothing to "close"; rename to `parse` or document
