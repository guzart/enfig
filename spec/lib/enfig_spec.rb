require_relative File.join('..', '..', 'lib', 'enfig')

require 'awesome_print'
require 'byebug'

describe Enfig do
  let(:filepath) { File.expand_path(File.join('..', 'sample.yml'), File.dirname(__FILE__)) }

  describe '::symbolize_keys' do
    it 'symbolizes the keys of a Hash' do
      config = Enfig.symbolize_keys('hello': 'world')
      expect(config[:hello]).to eq 'world'
    end
  end

  describe '#set_env' do
    it 'sets the config Hash to the ENV (environment variables) using upper case keys' do
      ENV['HELLO'] = nil
      Enfig.set_env(hello: 'World')
      expect(ENV['HELLO']).to eq 'World'
    end

    it 'overwrites the environment value if one is already set' do
      ENV['HELLO'] = 'my value'
      Enfig.set_env({ hello: 'World' }, overwrite: true)
      expect(ENV['HELLO']).to eq 'World'
    end

    it 'overwrites the environment value if one is already set' do
      ENV['HELLO'] = 'my value'
      Enfig.set_env({ hello: 'World' }, overwrite: false)
      expect(ENV['HELLO']).to eq 'my value'
    end
  end

  describe '::merge_config!' do
    it 'merges to hashes with a given key prefix and a separator' do
      target = { hello: 'world' }
      Enfig.merge_config!(target, { foo: 'bar' }, :test_)
      expect(target['test_foo']).to eq 'bar'
    end
  end

  describe '::flatten_config' do
    it 'returns nil if the given config is nil' do
      config = Enfig.flatten_config(nil)
      expect(config).to be_nil
    end

    it 'copies first level keys and values' do
      config = Enfig.flatten_config(name: 'My Enfig')
      expect(config[:name]).to eq 'My Enfig'
    end

    it 'flattens the nested hashes using the given separator' do
      config = Enfig.flatten_config({ database: { username: 'enfig' } }, separator: '/')
      expect(config['database/username']).to eq 'enfig'
    end

    it 'adds a given prefix only to the first level keys' do
      data = { database: { username: 'enfig' } }
      config = Enfig.flatten_config(data, prefix: 'app')
      expect(config['app_database_username']).to eq 'enfig'
    end
  end

  describe '::load_config' do
    it 'loads the symbolized keys from the yaml file' do
      config = Enfig.load_config(filepath)
      expect(config[:hello]).to eq 'World'
    end

    it 'flattens the keys from the given hash' do
      config = Enfig.load_config(filepath)
      expect(config[:production_hello]).to eq 'Bonjour'
    end

    it 'flattens the keys using the given separator' do
      config = Enfig.load_config(filepath, separator: '-')
      expect(config[:'production-hello']).to eq 'Bonjour'
    end

    it 'loads the configuration using the value of the given :root as a key' do
      config = Enfig.load_config(filepath, root: :production)
      expect(config[:hello]).to eq 'Bonjour'
    end
  end

  describe '::load!' do
    it 'use the RAILS_ENV environment value as the default root' do
      ENV['HELLO'] = nil
      ENV['RAILS_ENV'] = 'my_env'
      Enfig.load!(filepath)
      expect(ENV['HELLO']).to eq 'Guten Morgen'
    end
  end
end
