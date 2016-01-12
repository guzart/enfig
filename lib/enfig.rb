require 'psych'

class Enfig
  DEFAULTS = { overwrite: false, prefix: nil, root: nil, separator: '_' }

  def self.load_config(filename, options = {})
    opts = DEFAULTS.merge(symbolize_keys(options))
    root = opts[:root]

    data = Psych.load_file(filename)
    data = data[root.to_s] unless root.to_s.strip == ''
    @config = Enfig.symbolize_keys(Enfig.flatten_config(data, opts))
  end

  def self.set_env(config, options = {})
    opts = DEFAULTS.merge(symbolize_keys(options))
    overwrite = opts[:overwrite]

    config.each do |key, value|
      env_key = key.to_s.upcase
      next if !overwrite && !ENV[env_key].nil?
      ENV[env_key] = value
    end
  end

  # Flattens the deeply nested hashes into a single hash by joining the keys using the given separator
  # @param config [Hash] the hash to flatten
  # @param options [Hash] the options hash
  # @option options [String] :separator ('_') the key separator to use when joining the keys of a nested hash
  # @option options [String] :prefix (nil) the
  # @return [Hash] the flattened hash
  def self.flatten_config(config, options = {})
    return nil if config.nil?

    opts = DEFAULTS.merge(options)
    prefix = opts[:prefix]
    separator = opts[:separator].to_s

    output = {}
    config.each do |key, value|
      if value.is_a? Hash
        flat_value = flatten_config(value, separator: separator)
        base_key = [prefix, key.to_s, ''].compact.join(separator)
        merge_config!(output, flat_value, base_key)
        next
      end

      output[key] =  value
    end

    output
  end

  # Meges a source hash into a target hash by adding a prefix to the source hash keys.
  # @param target [Hash] the target hash that will be modified
  # @param source [Hash] the source hash that will be merge into the target
  # @param key_prefix [Symbol, String] the prefix for the keys in the target
  # @return [Hash] the target hash
  def self.merge_config!(target, source, key_prefix)
    source.each do |key, value|
      o_key = [key_prefix.to_s, key.to_s].join
      target[o_key] = value
    end

    target
  end

  # Symbolizes the first level keys of the given hash
  # @param hash [Hash] the source hash
  # @return [Hash] the hash with symbolized keys
  def self.symbolize_keys(hash)
    return nil if hash.nil?
    output = {}
    hash.each do |key, value|
      output[key.to_sym] = value
    end

    output
  end

  def self.load!(filename, options = {})
    rails_env = ENV['RAILS_ENV'].to_s.strip
    rails_env = nil if rails_env == ''
    args = { root: rails_env }.merge(options)

    config = load_config(filename, args)
    set_env(config, args)
    config
  end
end
