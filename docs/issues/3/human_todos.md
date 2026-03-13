## TODO (human): Uncomment `bcrypt` in `Gemfile` and run `bundle install`

```
gem "bcrypt", "~> 3.1.7"
```

## TODO (human): Run the Rails authentication generator

```
bin/rails generate authentication
```

This creates: `User`, `Session` models, `SessionsController`, `PasswordsController`, `PasswordsMailer`, the `Authentication` concern, and associated views and migrations.

## TODO (human): Run migrations

```
bin/rails db:migrate
```

## TODO (human): Seed a super admin user for development

Add to `db/seeds.rb`:

```ruby
User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = "password"
  u.role = :super_admin
end
```

Then run `bin/rails db:seed`
