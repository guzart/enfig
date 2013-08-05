require 'yaml'

class Enfig

  attr_accessor :env, :root, :files, :enable_overwrite

  alias_method :'overwrite?', :enable_overwrite

  def initialize(args = {})
    @config           = nil
    @env              = args[:env]        || 'development'
    @root             = args[:root]       || '.'
    @files            = args[:files]      || [args[:file]].compact
    @enable_overwrite = args[:overwrite] == false ? false : true
  end

  def config
    @config ||= load_config
  end

  def [](key)
    config[key]
  end

  def load_config
    conf = {}

    files.each do |file|
      name = File.basename(file, '.yml').to_s.downcase.to_sym
      conf[name] = load_yaml(file)
    end

    conf
  end

  def update_env!
    load_env_hash(config).each do |k, v|
      ENV[k] = v if ENV[k].nil? || ENV[k] == '' || overwrite?
    end
  end

  def self.update!(args = {})
    enfig = Enfig.new(args)
    enfig.update_env!
    enfig
  end

  private

    def load_yaml(*args)
      config = YAML.load_file(File.join(root, *args))
      symbolize_keys(config[env])
    end

    def load_env_hash(config_src, target = {}, prefix = nil)
      prefix.concat('_') if prefix && !prefix.end_with?('_')
      config_src.each do |key, value|
        suffix = key.to_s.upcase
        target_key = "#{prefix}#{suffix}"
        if value.is_a?(Hash)
          load_env_hash(value, target, target_key)
        else
          target[target_key] = value
        end
      end

      target
    end

    def symbolize_keys(hash)
      transform_keys(hash) { |key| key.to_sym rescue key }
    end

    def transform_keys(hash, &block)
      result = {}
      hash.each do |key, value|
        result[yield(key)] = value.is_a?(Hash) ? transform_keys(value, &block) : value
      end
      result
    end

end
