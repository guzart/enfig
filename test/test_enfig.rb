require 'test/unit'
require 'enfig'

require 'rubygems'
require 'ap'
require 'pry'

class EnfigTest < Test::Unit::TestCase

  def setup
    ENV['SAMPLE_HELLO'] = nil
    ENV['SAMPLE_S3_KEY'] = nil
  end

  def test_load_file_into_key_with_file_basename
    enfig = Enfig.new(:file => 'test/sample.yml')
    assert_not_nil enfig[:sample]
  end

  def test_load_file_using_development_environment_by_default
    enfig = Enfig.new(:file => 'test/sample.yml')
    assert_equal 'Hola', enfig[:sample][:hello]
  end

  def test_load_file_by_specific_environment
    enfig = Enfig.new(:env => 'production', :file => 'test/sample.yml')
    assert_equal 'Bonjour', enfig[:sample][:hello]
  end

  def test_load_file_from_nested_config
    enfig = Enfig.new(:file => 'test/sample.yml')
    assert_equal 'abcdefg12345', enfig[:sample][:s3][:key]
  end

  def test_update_env_variables
    enfig = Enfig.new(:file => 'test/sample.yml')
    enfig.update_env!
    assert_equal 'Hola', ENV['SAMPLE_HELLO']
  end

  def test_does_not_overwrite_env_variables_if_overwrite_is_false
    ENV['SAMPLE_HELLO'] = 'booya'
    enfig = Enfig.new(:file => 'test/sample.yml', :overwrite => false)
    enfig.update_env!
    assert_equal 'booya', ENV['SAMPLE_HELLO']
  end

  def test_overwrite_env_variables_if_overwrite_is_true
    ENV['SAMPLE_HELLO'] = 'booya'
    enfig = Enfig.new(:file => 'test/sample.yml', :overwrite => true)
    enfig.update_env!
    assert_equal 'Hola', ENV['SAMPLE_HELLO']
  end

  def test_updated_env_variables_from_nested_config
    enfig = Enfig.new(:file => 'test/sample.yml')
    enfig.update_env!
    assert_equal 'abcdefg12345', ENV['SAMPLE_S3_KEY']
  end

  def test_class_method_update_sets_env_variables
    Enfig.update!(:file => 'test/sample.yml')
    assert_equal 'abcdefg12345', ENV['SAMPLE_S3_KEY']
  end

end
