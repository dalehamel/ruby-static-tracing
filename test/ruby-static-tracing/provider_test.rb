# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class ProviderTest < MiniTest::Test
    def setup
      @namespace = 'tracing'
      @provider = Provider.register(@namespace)
    end

    def test_instance_not_found
      assert_raises Provider::ProviderNotFound do
        Provider.fetch('not_registered')
      end
    end

    def test_provider
      assert_equal @provider, Provider.fetch(@namespace)
    end
  end
end
