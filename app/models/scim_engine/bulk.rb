module ScimEngine
  class Bulk < Supportable
    attr_accessor :maxOperations, :maxPayloadSize
  end
end
