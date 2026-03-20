# Improvement Plan

All items completed.

## Critical

1. ~~**`.gitignore` incomplete** — Add `coverage/`, `pkg/`, `*.gem`, `.env`~~ DONE
2. ~~**Gemspec references `README.rdoc` but file is `README.md`** — Line 16 of gemspec excludes README from the published gem~~ DONE

## High — CI/CD

1. ~~**No actual test CI** — `.github/workflows/ci.yml` only runs SonarCloud, no Ruby/MongoDB test execution. Add a proper workflow with a Ruby + MongoDB service matrix~~ DONE
2. ~~**Gem publish workflow uses unmaintained action** — `cadwallion/publish-rubygems-action@master` is pinned to `@master`, not a tagged version. Switch to tagged action or manual trigger~~ DONE
3. ~~**`actions/checkout@v3` is outdated** — Upgrade to v4 in both workflows~~ DONE

## Medium — Metadata and Docs

1. ~~**Missing gemspec metadata** — Add `homepage_uri`, `source_code_uri`, `changelog_uri`, `bug_tracker_uri`~~ DONE
2. ~~**No CHANGELOG.md** — Replaced with auto-generated GitHub Release notes~~ DONE
3. ~~**`sonar-project.properties` version is stale** — Still says 0.3.1, should be 0.4.0~~ DONE
4. ~~**README uses deprecated Rails 4 syntax** — `get :show, id: @user` should be `get :show, params: { id: @user }`~~ DONE
5. ~~**README doesn't document ERB or `$LABEL` support** — Both are supported features but undocumented~~ DONE

## Medium — Test Coverage

1. ~~**Thin test suite (~10 tests)** — Missing coverage for error paths, reload flag, $LABEL, timestamps, DEFAULTS, ERB, embedded docs~~ DONE (29 tests, 68 assertions, 94% coverage)
2. ~~**Test style issues** — `require 'pry'` left in test file, `begin/rescue/assert(false)` pattern instead of idiomatic `assert_raises`~~ DONE

## Lower — Code Quality

1. ~~**Silent error swallowing in `find_or_create_document`** — Rescues `StandardError` and logs to `Rails.logger` which may not exist outside Rails~~ DONE
2. ~~**`# type code here` placeholder comments** — Two `else` branches in `util.rb` have stale placeholders~~ DONE
3. ~~**Broad `rescue StandardError` in `apply_embedded_attributes`** — Narrowed to `Mongoid::Errors::MongoidError`~~ DONE
4. ~~**`update_document` mutates input hash** — Now works on a duplicate via `attributes.dup`~~ DONE
