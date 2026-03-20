# mongoid-fixture_kit

[![Version](https://img.shields.io/gem/v/mongoid-fixture_kit.svg?style=square)](https://rubygems.org/gems/mongoid-fixture_kit)
[![Download](https://img.shields.io/gem/dt/mongoid-fixture_kit.svg?style=square)](https://rubygems.org/gems/mongoid-fixture_kit)
[![License](https://img.shields.io/github/license/siposdani87/mongoid-fixture-kit.svg?style=square)](./LICENSE)

<a href="https://www.buymeacoffee.com/siposdani87" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-green.png" alt="Buy Me A Coffee" width="150" height="39" /></a>

This package is a Ruby gem that provides a way to load sample data into a MongoDB database for testing purposes. It provides a simple and convenient way to manage test data by defining fixtures in YAML files, which can be loaded into the database before running tests.

This library aims to provide fixtures for Mongoid the same way you have them with ActiveRecord.

## Getting Started

### Installing

```ruby
gem 'mongoid-fixture_kit'
```

### Usage

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
    get :show, params: { id: @user }
    assert_response :success
  end
end
```

### Features

- Creation of a document from a YAML file
- ERB inside YAML files
- `$LABEL` interpolation in fixture values
- `belongs_to` relations
- Polymorphic `belongs_to`
- `has_many` relations
- `has_and_belongs_to_many` relations
- Embedded documents (`embeds_one`, `embeds_many`)
- `DEFAULTS` key for shared fixture attributes
- `TestHelper` module to include in your tests

### ERB in Fixtures

You can use ERB in your YAML fixture files to generate dynamic data:

```yaml
<% 5.times do |i| %>
school<%= i %>:
  name: School <%= i %>
<% end %>
```

### Label Interpolation

Use `$LABEL` in fixture values to reference the fixture's own name:

```yaml
user_john:
  username: $LABEL
  email: $LABEL@example.com
```

This will set `username` to `"user_john"` and `email` to `"user_john@example.com"`.

### Defaults

Use the `DEFAULTS` key to define shared attributes for all fixtures in a file:

```yaml
DEFAULTS:
  role: member

admin:
  name: Admin
  role: admin

regular_user:
  name: Regular User
```

The `DEFAULTS` entry is removed during loading and is not inserted as a document.

### Compatibility

| Dependency | Supported versions |
|---|---|
| Ruby | 3.1, 3.2, 3.3, 3.4 |
| Mongoid | 7.x, 8.x, 9.x |
| Rails (ActiveSupport) | 7.0+ |

### Notes

Documents are stored with a special attribute `__fixture_name` which is used to retrieve it and establish relations.

`Mongoid::Document` has a `attr_accessor` defined for `__fixture_name`, so it doesn't pose any problem if you try to `dup` a document for example.

### Changes compared to ActiveRecord

- There is an option to load fixtures only once.
- Fixture accessor methods are defined publicly.

These changes are here to let you create another class holding persistent data inside your tests.

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

If you encounter any problems feel free to open an [issue](https://github.com/siposdani87/mongoid-fixture-kit/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/siposdani87/mongoid-fixture-kit/issues/new?template=feature_request.md). Pull request are also welcome.

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=b992bb656478&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)

## Developer

[Dániel Sipos](https://siposdani87.com)

## Sponsors

This project is generously supported by [TrophyMap](https://trophymap.org), [I18Nature](https://i18nature.com), and several other amazing organizations.
