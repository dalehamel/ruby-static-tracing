module StaticTracing
  def self.linux?
    /linux/.match(RUBY_PLATFORM)
  end
end
