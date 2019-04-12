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

    def self.add_custom_resource(resource)
      custom_resources << resource
    end

    def self.custom_resources
      @custom_resources ||= []
    end

    def self.default_resources
      [ Resources::User, Resources::Group ]
    end

    def self.schemas
      resources.map(&:schemas).flatten.uniq.map(&:new)
    end

  end
end
