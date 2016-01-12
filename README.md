enfig
=====

Sets environment `ENV[]` values from a YAML file.

## Why?

When a project starts growing so does it settings. After a while you end up with multiple
YAML files, one for each component, and it becomes hard to manage.

This gem lets you group all of your project settings into one YAML file in your project.
It then adds the settings to the ENV, so that you can use the `ENV[key]` in your code.

## Installation

Install the gem by adding it to  your `Gemfile`

`gem 'enfig', '~> 1.0.0'`

Then just simply call the `::load!` method, anywhere in your application,
for Rails applications add it before project module in `config/application.rb` file.

`Enfig.load! 'config/project.yml', overwrite: true`

## API

The `::load!` methods take the filename as the first parameter and an optional hash as a second
parameter.

### Options

**root** *[String]*  
*Default: nil*  
The key to consider as the root of the configuration values. This is useful when working with multiple environments.

**separator** *[String]*  
*Default: '_'*  
The separator to use when flattening the key of nested hashes.

**overwrite** *[Boolean]*  
*Default: false*  
Indicates if the existing `ENV[]` values can be overwritten.

### Example

```YAML
    # config/project.yml

    # Thanks to YAML you can reuse pieces of your configuration

    database: &database
      adapter: postgresql
      host: localhost
      database: project_db
      username: db_user
      password: abcdefg123456

    development:
      database:
        <<: *database

    production:
      database:
        <<: *database
        host: server.example.com
        password: seriouspassword
```

```ruby
# config/application.rb

# Load the environment variables before loading Rails
Enfig.load! "#{Rails.root}/config/project.yml", env: 'production', separator: '_', overwrite: true
```

Will result in setting the following ENV values.

```ruby
ENV['DATABASE_ADAPTER']  = 'postgresql'
ENV['DATABASE_HOST']     = 'server.example.com'
ENV['DATABASE_DATABASE'] = 'project_db'
ENV['DATABASE_USERNAME'] = 'db_user'
ENV['DATABASE_PASSWORD'] = 'seriouspassword'
```
