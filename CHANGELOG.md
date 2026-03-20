# Changelog

## 0.4.0

- Add support for embedded document handling in Mongoid 8+ (extract/apply embedded attributes)
- Resolve `belongs_to` fixture references within embedded documents
- Relax gem dependency constraints (use pessimistic version operators)
- Add real CI workflow with Ruby 3.1/3.2/3.3 matrix and MongoDB service
- Switch gem publish to tag-triggered workflow
- Add gemspec metadata URIs
- Fix gemspec including `README.rdoc` instead of `README.md`
- Guard `Rails.logger` usage for non-Rails environments
- Expand test suite (29 tests, 94% coverage)
- Document ERB and `$LABEL` fixture features in README

## 0.3.1

- Add Rails 8 compatibility
- Update dependencies

## 0.3.0

- Initial release under `mongoid-fixture_kit` name
- Support for `belongs_to`, `has_many`, `has_and_belongs_to_many` relations
- Polymorphic relation support
- ERB inside YAML fixtures
- `TestHelper` module with fixture accessors
- `load_fixtures_once` option
