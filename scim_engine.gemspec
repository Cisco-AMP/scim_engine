$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scim_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scim_engine"
  s.version     = ScimEngine::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = 'https://gemdist.immunet.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  s.add_dependency "rails", "5.0.7.2"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'byebug'
end
