require_dependency "scim_engine/application_controller"

module ScimEngine
  class SchemasController < ApplicationController
    def index
      schemas = ScimEngine::Engine.schemas
      schemas_by_id = schemas.reduce({}) do |hash, schema|
        hash[schema.id] = schema
        hash
      end

      render json: schemas_by_id[params[:name]] || schemas
    end

  end
end
