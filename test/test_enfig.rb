require 'test/unit'
require 'enfig'

class EnfigTest < Test::Unit::TestCase

  def test_load_config_by_environment
    enfig = Enfig.new(:env => 'development', :file => 'test/config.yml')
    enfig.load_config
    assert_equal 'Hola', enfig[:config][:hello]
  end

end
