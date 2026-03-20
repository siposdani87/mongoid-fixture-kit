# Improvement Plan

## Round 1 — Completed

1. ~~`.gitignore` incomplete~~ DONE
2. ~~Gemspec references `README.rdoc` instead of `README.md`~~ DONE
3. ~~No actual test CI~~ DONE
4. ~~Gem publish workflow uses unmaintained action~~ DONE
5. ~~`actions/checkout@v3` outdated~~ DONE
6. ~~Missing gemspec metadata~~ DONE
7. ~~No CHANGELOG — replaced with auto-generated GitHub Release notes~~ DONE
8. ~~`sonar-project.properties` version stale~~ DONE
9. ~~README uses deprecated Rails 4 syntax~~ DONE
10. ~~README doesn't document ERB or `$LABEL` support~~ DONE
11. ~~Thin test suite — expanded to 29 tests, 94% coverage~~ DONE
12. ~~Test style issues (`require 'pry'`, `begin/rescue/assert(false)`)~~ DONE
13. ~~Silent error swallowing in `find_or_create_document`~~ DONE
14. ~~Placeholder comments in `util.rb`~~ DONE
15. ~~Broad `rescue StandardError` in `apply_embedded_attributes`~~ DONE
16. ~~`update_document` mutates input hash~~ DONE

## Round 2 — Security

1. **Create `.env.example`** with placeholder values so contributors know which env vars to set

## Round 2 — Build and Lint

1. **Fix RuboCop offenses** — 12 violations, 9 autocorrectable via `rubocop -A`
2. **`.rubocop.yml` invalid `TargetRubyVersion: 3.1.x`** — should be `3.1`
3. **Re-enable `Lint/ShadowingOuterLocalVariable`** — currently disabled, masks real bugs
4. **Add Ruby 3.4 to CI matrix** — current stable missing
5. **Add Linux platform to `Gemfile.lock`** — `bundle lock --add-platform x86_64-linux` for CI

## Round 2 — Code Quality (Bugs)

1. **`false`/`nil` values lost in `update_document`** — `attributes[key] || document[key]` skips `false`; use `attributes.key?(key) ? attributes[key] : document[key]` (util.rb:87)
2. **Array concatenation without dedup** — HABTM can get duplicate IDs; add `.uniq` (util.rb:91)
3. **`find_or_create_document` still rescues broad `StandardError`** — narrow to `Mongo::Error, Mongoid::Errors::MongoidError` (util.rb:160)
4. **`unmarshall_belongs_to` mutates string via `sub!`** — use non-destructive `sub` (util.rb:299)

## Round 2 — Tests

1. **`load_once_test.rb` still uses `begin/rescue/assert(false)`** — replace with `assert_nothing_raised`
2. **`file_test.rb` empty blocks trigger RuboCop** — use `f.to_a` instead
3. **Missing unit tests** — `ClassCache`, `RenderContext`, `Fixture#each`/`Fixture#[]`, non-hash row `FormatError`
4. **Split mega-test** `test_should_create_fixtures` (20+ assertions) into focused per-relation tests

## Round 2 — Docs and CI

1. **README missing compatibility matrix** — tested Ruby and Mongoid versions
2. **README missing `DEFAULTS` key documentation**
3. **SonarCloud coverage broken** — test job doesn't upload artifacts for sonarcloud job
4. **`test.sh` not integrated into CI** — rubocop JSON report not produced in CI

## Round 2 — Lower Priority

1. **`FixtureKit.context_class` leaks state** — accumulated modules never reset
2. **`Fixture` includes `Enumerable` unnecessarily** — confusing API surface
3. **`read_fixture_files` no graceful error for missing YAML** — `Errno::ENOENT` with no context
