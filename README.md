enfig
=====

Sets `ENV[]` values from a YAML file.

## Why?

When a project starts growing so does it settings. After a while you end up with multiple
YAML files, one for each component, and it becomes hard to manage.

This gems let's you group all your project settings in one YAML file and in your project
directory. It then adds them to the ENV, so that you can use the `ENV[key]` in your code.

## How?

Install the gem by adding it to  your `Gemfile`

`gem 'enfig', '~> 0.1.0'`

Then anywhere in your application, if it's a rails application you could add it to the
bottom of the `config/boot.rb` file.

Then just simply call the `::update!` method.

`Enfig.update! :env => ENV['RAILS_ENV'], :file => File.join('config', 'my_project.yml')

## Options

The `::update!` and `#initialize` methods take a hash with the following keys:

* **:env** => String -- The environment name
* **:root** => String -- The root path
* **:files** => Array -- The array of YAML files to load, relative to the `:root` path
* **:file** => String -- A single YAML file to load, relative to the `:root` path. This option
  is ignored if the `:files` options is specified.
* **:overwrite** => Boolean -- Indicates if the `ENV[]` values can be overwritten.

### Example

Given the following file in `"#{Rails.root}/config/database.yml"`

    development: &defaults
      adapter: postgresql
      host: localhost
      database: dev_db
      encoding: utf8
      pool: 5
      timeout: 5000
      username: dev_user
      password: abcdefg123456

    production:
      <<: *defaults
      username: prod_user

`Enfig.update! :env => 'production', :root => 'config', :file => 'database.yml'`

Will set the following ENV values.

    ENV['DATABASE_ADAPTER'] = 'postgresql'
    ENV['DATABASE_USERNAME'] = 'prod_user'

As you can see from the example `Enfig` will **ignore the environment key name**.
