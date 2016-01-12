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

Then just simply call the `::load!` method, anywhere in your application.

### Rails

For Rails applications add the following snippet at the bottom of the `config/boot.rb` file.

```ruby
# config/boot.rb
require 'enfig'
Enfig.load! File.expand_path('../project.yml', __FILE__)
```

Replace `project.yml` with the name of your configuration file.

## API

The `::load!` methods take the filename as the first parameter and an optional hash as a second
parameter.

`Enfig.load!(filename:String, [options:Hash])`

### Options

**root** *[String, Symbol]*  
*Default: nil*  
The key to consider as the root of the configuration values. This is useful when working with multiple environments.

**prefix** *[String]*  
*Default: nil*  
The prefix for the environment keys.

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
Enfig.load! 'project.yml', root: :production, prefix: 'app', separator: '/', overwrite: true
```

Will result in setting the following ENV values.

```ruby
ENV['APP/DATABASE/ADAPTER']  = 'postgresql'
ENV['APP/DATABASE/HOST']     = 'server.example.com'
ENV['APP/DATABASE/DATABASE'] = 'project_db'
ENV['APP/DATABASE/USERNAME'] = 'db_user'
ENV['APP/DATABASE/PASSWORD'] = 'seriouspassword'
```

*Note: How the configuration hash results in the keys being  prefixed with `APP` and joined with a '/' separator*
