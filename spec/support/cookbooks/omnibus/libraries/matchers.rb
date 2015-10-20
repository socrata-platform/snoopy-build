if defined?(ChefSpec)
  {
    ruby_gem: %i(install),
    omnibus_build: %i(execute)
  }.each do |matcher, actions|
    ChefSpec.define_matcher(matcher)
    actions.each do |action|
      define_method("#{action}_#{matcher}") do |name|
        ChefSpec::Matchers::ResourceMatcher.new(matcher, action, name)
      end
    end
  end
end
