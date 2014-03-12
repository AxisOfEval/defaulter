# Defaulter [![Gem Version](https://badge.fury.io/rb/defaulter.png)](http://badge.fury.io/rb/defaulter)

Defaulter allows you to mark and maintain default objects in ActiveRecord association collections with minimal code and minimal fuss.

For example, a `User` model can have many `Email` models using ActiveRecords `has_many` functionality. But which email address do you send mail to? Certainly not all, that's just irritating. Instead, marking a particular record as default and sending mail there is a much better idea. The defaulter gem allows you to achieve that rather simply.

## Compatibility

Besides Rails 4 beta, defaulter now supports Rails 3.2. It **may work** on lower rails versions, but your mileage may vary.

## Installation

### Step 1

Put this in your project's Gemfile:

```ruby
gem 'defaulter'
```

Don't forget to run the `bundle` command to fetch the gem.

### Step 2

Next, you'll need to add one column to whichever table where you want to mark default records. Since both `default` and `primary` are reserved words in SQL, we go with the name `prime`. If you're making a migration afresh, tuck the following line in your migration's `create_table` call:

```ruby
t.boolean :prime, null: false, default: false
```

If already have a migration, you will need to create a new one and add the column like so:

```ruby
add_column :table_name, :prime, null: false, default: false
```

Now, run the migrations.

*NOTE:* Adding proper indexes will speed-up your finds.

### Step 3

There's no *Step 3*. We're ready to roll.

## Configuration

The defaulter gem gives you a `has_default` call that sets up the model and the `has_many` association automatically for you. Going with our `User` and `Email` example, a user can have many emails, one of which may be a default record. The `User` class can look like so:

```ruby
class User < ActiveRecord::Base
  has_default :email
end
```

*NOTE:* There is no need to add `has_many :emails`, `has_default :email` does that for you automatically. Also all of the `has_many` options, including polymorphism are supported.

The `Email` class can go unchanged:

```ruby
class Email < ActiveRecord::Base
  belongs_to :user
end
```

## Usage

Usage is surprisingly simple. Defaulter extends ActiveRecord for getting and setting a default record like so.

### Getter

If you've followed along carefully, `user.emails` should get you all the email addresses; and, `user.emails.default` should get you the default email address.

### Setter

To set a new default email, `user.emails.default = user.emails.last` will set a new default email address. The older default record will now longer be the default.

*NOTE:* The new default record will have to exist in the collection before you can set it as a new default.

### Adding

Defaulter overides ActiveRecord's `<<` so that a new record or collections can be added. If the new record is marked as default by setting `prime` to `true`, the existing default record will cease to be one. If a collection has more than one item marked as default, the last item will take precendence. In short, defaulter will do eveything it can to ensure that there is just one default record on the database for an association collection at any given time.

## Contributing

I threw this gem together in about half an hour, there is scope for improvement. I will appreciate contributions in the following areas:

1. Tests, Tests, Tests
2. Ability the configure the name of the default column, by passing it with the `has_default` call like so: `has_default :email, default_column: :primordial`
3. Dynamically generated utitlity instance methods like `default_email` and `default_address`
4. Optionally, prevent default records from being destroyed
5. ~~Backport to Rails 3.2~~ (v0.0.9)

## License

MIT License. Copyright &copy; 2013 Amol Hatwar.

