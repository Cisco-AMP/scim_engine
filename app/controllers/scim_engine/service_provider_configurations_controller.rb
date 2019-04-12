require_dependency "scim_engine/application_controller"
module ScimEngine
  class ServiceProviderConfigurationsController < ApplicationController
    def show
      render json: ScimEngine.service_provider_configuration(location: request.url)
    end
  end
end
