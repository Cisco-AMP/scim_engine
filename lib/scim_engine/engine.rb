module ScimEngine
  class Engine < ::Rails::Engine
    isolate_namespace ScimEngine

    Mime::Type.register "application/scim+json",:scim

    ActionDispatch::Request.parameter_parsers[Mime::Type.lookup('application/scim+json').symbol] = lambda do |body|
      JSON.parse(body)
    end

    mattr_accessor :username
    mattr_accessor :password

    def self.resources
      default_resources + custom_resources
    end

    # Can be used to add a new resource type which is not provided by the gem.
    # @example
    #  module Scim
    #    module Resources
    #      class ShinyResource < ScimEngine::Resources::Base
    #        set_schema Scim::Schema::Shiny
    #
    #        def self.endpoint
    #          "/Shinies"
    #        end
    #      end
    #    end
    #  end
    #  ScimEngine::Engine.add_custom_resource Scim::Resources::ShinyResource
    def self.add_custom_resource(resource)
      custom_resources << resource
    end

    # Returns the list of custom resources, if any.
    def self.custom_resources
      @custom_resources ||= []
    end

    # Returns the default resources added in this gem: User and Group.
    def self.default_resources
      [ Resources::User, Resources::Group ]
    end

    def self.schemas
      resources.map(&:schemas).flatten.uniq.map(&:new)
    end

  end
end
