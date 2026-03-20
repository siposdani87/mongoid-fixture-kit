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

1. ~~**Create `.env.example`** with placeholder values~~ DONE

## Round 2 — Build and Lint

1. ~~**Fix RuboCop offenses** — all resolved, 0 offenses~~ DONE
2. ~~**`.rubocop.yml` invalid `TargetRubyVersion: 3.1.x`** — fixed to `3.1`~~ DONE
3. ~~**Re-enable `Lint/ShadowingOuterLocalVariable`** — enabled and fixed~~ DONE
4. ~~**Add Ruby 3.4 to CI matrix**~~ DONE
5. ~~**Add Linux platform to `Gemfile.lock`**~~ DONE

## Round 2 — Code Quality (Bugs)

1. ~~**`false`/`nil` values lost in `update_document`** — fixed with `attributes.key?` check~~ DONE
2. ~~**Array concatenation without dedup** — added `.uniq`~~ DONE
3. ~~**`find_or_create_document` rescues broad `StandardError`** — narrowed to `Mongo::Error, Mongoid::Errors::MongoidError`~~ DONE
4. ~~**`unmarshall_belongs_to` mutates string via `sub!`** — changed to non-destructive `match?`/`sub`~~ DONE

## Round 2 — Tests

1. ~~**`load_once_test.rb` uses `begin/rescue/assert(false)`** — replaced with `assert_nothing_raised`~~ DONE
2. ~~**`file_test.rb` empty blocks** — replaced with `f.to_a`~~ DONE
3. ~~**Missing unit tests** — added ClassCache, RenderContext, Fixture, non-hash row FormatError~~ DONE
4. ~~**Split mega-test** — split into BelongsTo, HasMany, HABTM, Embedded, DocumentCount tests~~ DONE

## Round 2 — Docs and CI

1. ~~**README missing compatibility matrix**~~ DONE
2. ~~**README missing `DEFAULTS` key documentation**~~ DONE
3. ~~**SonarCloud coverage broken** — added artifact upload/download between jobs~~ DONE
4. ~~**`test.sh` not integrated into CI** — CI now produces rubocop JSON report~~ DONE

## Round 2 — Lower Priority

1. **`FixtureKit.context_class` leaks state** — accumulated modules never reset
2. **`Fixture` includes `Enumerable` unnecessarily** — confusing API surface
3. **`read_fixture_files` no graceful error for missing YAML** — `Errno::ENOENT` with no context
