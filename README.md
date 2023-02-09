# mongoid-fixture_kit

[![Version](https://img.shields.io/gem/v/mongoid-fixture_kit.svg?style=square)](https://rubygems.org/gems/mongoid-fixture_kit)
[![Download](https://img.shields.io/gem/dt/mongoid-fixture_kit.svg?style=square)](https://rubygems.org/gems/mongoid-fixture_kit)
[![License](https://img.shields.io/github/license/siposdani87/mongoid-fixture-kit.svg?style=square)](./LICENSE)

<a href="https://www.buymeacoffee.com/siposdani87" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-green.png" alt="Buy Me A Coffee" width="150" height="39" /></a>

This package is a Ruby gem that provides a way to load sample data into a MongoDB database for testing purposes. It provides a simple and convenient way to manage test data by defining fixtures in YAML files, which can be loaded into the database before running tests.

This ruby gem aims to provide fixtures for Mongoid the same way you have them with ActiveRecord.

## Install

```ruby
gem 'mongoid-fixture_kit'
```

## How to use

In your tests, add:

```ruby
class ActiveSupport::TestCase
  include Mongoid::FixtureKit::TestHelper
  self.fixture_path = "#{Rails.root}/test/fixtures"
end
```

This is also done by `ActiveRecord`, but magically in the railties.

Then when you want to access a fixture:

```ruby
class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:user_1)
  end
  
  test 'should show user' do
    get :show, id: @user
    assert_response :success
  end
end
```

## Features

- Creation of a document from an YAML file.
- `belongs_to` relations
- ERB inside YAML files
- YAML DEFAULTS feature
- Polymorphic `belongs_to`
- `has_many` relations
- `has_and_belongs_to_many` relations
- `TestHelper` module to include in your tests

## Notes

Original fixtures from `ActiveRecord` also uses a selection based on `class_names` for which I haven't seen any use case, so I did not port this feature yet.

I did not find how `ActiveRecord::TestFixtures` defines its `fixture_table_names` so I'm simply searching for *all* YAML files under `self.fixture_path`, which is enough for what I want.

Array attributes are receiving a special treatment, i.e. they are joined with new values, not replaced by the new one. This is used for `has_and_belongs_to_many` relations.

Documents are stored with a special attribute `__fixture_name` which is used to retrieve it and establish relations.

`Mongoid::Document` has an `attr_accessor` defined for `__fixture_name` so it doesn't pose any problem if you try to `dup` a document for example.

## Changes compared to ActiveRecord

- There is an option to load fixtures only once.
- Fixture accessor methods are defined publicly.

This changes are here to let you create another class holding persistent data inside your tests.

```ruby
class TestData
  include Mongoid::FixtureKit::TestHelper

  self.fixture_path = "#{Rails.root}/test/fixtures_universes"
  self.load_fixtures_once = true

  def TestData.instance
    @instance ||= ->(){
      instance = new
      instance.setup_fixtures
      instance
    }.call
  end

  private_class_method :new
end

class ActiveSupport::TestCase
  include Mongoid::FixtureKit::TestHelper
  self.fixture_path = "#{Rails.root}/test/fixtures"

  def data
    TestData.instance
  end
end

# somewhere else
test 'should validate complex data structure' do
  assert_nothing_raised do
    DataStructure.process(data.structures(:complex))
  end
end
```

## License

The original version of this library is [mongoid-fixture_set](https://github.com/Aethelflaed/mongoid-fixture_set) by Geoffroy Planquart in 2014

## Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/siposdani87/sui-js/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/siposdani87/sui-js/issues/new?template=feature_request.md). Pull request are also welcome.

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=b992bb656478&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

## Developer

[Dániel Sipos](https://siposdani87.com)

## Sponsors

This project is generously supported by [TrophyMap](https://trophymap.org), [I18Nature](https://i18nature.com), and several other amazing organizations.
