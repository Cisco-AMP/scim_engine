require_dependency "scim_engine/application_controller"

module ScimEngine
  class ResourcesController < ApplicationController

    def show(&block)
      scim_user = yield resource_params[:id]
      render json: scim_user
    rescue ErrorResponse => error
      handle_scim_error(error)
    end

    def create(resource_type, &block)
      if resource_params[:id].present? || resource_params[:externalId].present?
        handle_scim_error(ErrorResponse.new(status: 400, detail: 'id and externalId are not valid parameters for create'))
        return
      end
      with_scim_resource(resource_type) do |resource|
        render json: yield(resource, is_create: true), status: :created
      end
    end

    def update(resource_type, &block)
      with_scim_resource(resource_type) do |resource|
        render json: yield(resource)
      end
    end

    def destroy
      if yield(resource_params[:id]) != false
        head :no_content
      else
        handle_scim_error(ErrorResponse.new(status: 500, detail: "Failed to delete the resource with id '#{params[:id]}'. Please try again later"))
      end
    end

    protected

    def validate_request
      if request.raw_post.blank?
        raise ScimEngine::ErrorResponse.new(status: 400, detail: 'must provide a request body')
      end
    end

    def with_scim_resource(resource_type)
      validate_request
      begin
        resource = resource_type.new(resource_params.to_h)
        unless resource.valid?
          raise ScimEngine::ErrorResponse.new(status: 400,
                                              detail: "Invalid resource: #{resource.errors.full_messages.join(', ')}.",
                                              scimType: 'invalidValue')
        end

        yield(resource)
      rescue NoMethodError => error
        Rails.logger.error error
        raise ScimEngine::ErrorResponse.new(status: 400, detail: 'invalid request')
      end
    rescue ScimEngine::ErrorResponse => error
      handle_scim_error(error)
    end

    private

    def resource_params
      params.permit!
    end

  end
end
