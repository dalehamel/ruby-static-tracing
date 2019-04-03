require 'test_helper'

module StaticTracing
  class ProviderTest < MiniTest::Test
    def setup
      @namespace = 'tracing'
      @provider = Provider.register(@namespace)
    end

    def test_instance
      assert_equal @provider, Provider.instance(@namespace)
    end

    def test_instance_will_create_a_new_provider_if_one_doesnt_exist
      provider = Provider.instance('testing')
      assert_instance_of Provider, provider
      refute_equal @provider, provider
    end

    def test_register
      refute_equal @provider, Provider.register(@namespace)
    end
  end
end
