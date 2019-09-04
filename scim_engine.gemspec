$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "scim_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "scim_engine"
  s.version     = ScimEngine::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "https://github.com/Cisco-AMP/scim_engine"
  s.summary     = "A general purpase SCIM implementation that could be plugged into rails applications as an engine to provide SCIM functionality."
  s.description = "There's no general purpose SCIM SDK for Ruby on Rails. As a result, anyone implementing SCIM will need to take care of the SCIM schema and
protocol, which may take a significant overhead compared the implementation of the actual APIs. This project aims to extract SCIM specifics as a rails engine that can be plugged into a Ruby on Rails project."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  s.add_dependency "rails", ">= 5.0"
  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_development_dependency 'rspec-rails', '3.8.2'
  s.add_development_dependency 'factory_bot_rails', '4.11.1'
  s.add_development_dependency 'byebug', '10.0.2'
end
