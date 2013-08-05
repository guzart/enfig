require 'yaml'

class Enfig

  attr_reader :config
  attr_accessor :env, :root, :files, :enable_overwrite

  alias_method :'overwrite?', :enable_overwrite

  def initialize(args = {})
    @config           = {}
    @env              = args[:env]  || ENV['RAILS_ENV'] || ENV['ENV'] || 'development'
    @root             = args[:root] || '.'
    @files            = args[:files] || [args[:file]].compact
    @enable_overwrite = args[:overwrite]
    add_rails_files if args[:rails]
  end

  def [](key)
    config[key]
  end

  def load_config
    @config = {}

    files.each do |file|
      name = File.basename(file, '.yml').to_s.downcase.to_sym
      @config[name] = load_yaml(file)
    end

    @config
  end

  private

    def add_rails_files
      @files << [File.join('config', 'project.yml'), File.join('config', 'database.yml')]
    end

    def load_yaml(*args)
      config = YAML.load_file(File.join(root, *args))
      symbolize_keys(config[env])
    end

    def fill_env_hash(config_src, target = {}, prefix = nil)
      prefix.concat('_') if prefix && !prefix.end_with?('_')
      config_src.each do |key, value|
        suffix = key.to_s.upcase
        if value.is_a?(Hash)
          fill_env_hash(value, target, suffix)
        else
          target["#{prefix}#{suffix}"] = value
        end
      end
      target
    end

    def symbolize_keys(hash)
      transform_keys(hash) { |key| key.to_sym rescue key }
    end

    def transform_keys(hash)
      result = {}
      hash.each_key do |key|
        result[yield(key)] = hash[key]
      end
      result
    end

end
