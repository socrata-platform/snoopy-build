# Encoding: UTF-8

if defined?(ChefSpec)
  {
    apt_update: %i(periodic),
    apt_repository: %i(add)
  }.each do |matcher, actions|
    ChefSpec.define_matcher(matcher)

    actions.each do |action|
      define_method("#{action}_#{matcher}") do |name|
        ChefSpec::Matchers::ResourceMatcher.new(matcher, action, name)
      end
    end
  end
end
