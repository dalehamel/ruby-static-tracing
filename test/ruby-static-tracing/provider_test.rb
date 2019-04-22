# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class ProviderTest < MiniTest::Test
    def setup
      @namespace = 'tracing'
      @provider = Provider.register(@namespace)
    end

    def teardown
      Provider.clean
    end

    def test_instance_not_found
      assert_raises Provider::ProviderNotFound do
        Provider.fetch('not_registered')
      end
    end

    def test_provider
      assert_equal @provider, Provider.fetch(@namespace)
    end

    def test_add_tracepoint
      tracepoint = @provider.add_tracepoint('my_method', Integer, String)
      assert_instance_of Tracepoint, tracepoint
      assert_equal @provider.tracepoints.length, 1
    end

    def test_provider_starts_disabled
      p = Provider.register('starts_disabled')
      refute p.enabled?
      refute @provider.enabled?
    end

    def test_new_provider_empty_path
      assert_empty(@provider.path)
    end

    def test_enable_provider
      refute(@provider.enabled?)
      assert(@provider.enable)
      assert(@provider.enabled?)
      @provider.disable
    end

    # FIXME: this is expected to fail on darwin
    def test_enabled_provider_has_nonempty_path
      refute(@provider.enabled?)
      assert(@provider.enable)
      assert(@provider.enabled?)
      refute_empty(@provider.path)
      @provider.disable
    end

    def test_disabled_provider_has_empty_path
      refute(@provider.enabled?)
      assert(@provider.enable)
      assert(@provider.enabled?)
      @provider.disable
      assert_empty(@provider.path)
    end

    def test_disable_provider
      refute(@provider.enabled?)
      assert(@provider.enable)
      assert(@provider.enabled?)
      @provider.disable
      refute(@provider.enabled?)
    end
  end
end
