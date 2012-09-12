module CleanModel

  class Error < StandardError
  end

  class InvalidTypeAssignment < Error
    def initialize(attribute, value)
      super "#{value} is not valid for #{attribute}"
    end
  end

  class UndefinedPersistenceMethod < Error
    def initialize(klass, method)
      super "#{klass} must define method [#{method}]"
    end
  end

  class InvalidResponse < Error
    def initialize(response)
      super response.content_type == 'application/json' ? response.body : "#{response.code} - Unexpected error"
    end
  end

  class ConnectionFail < Error
    def initialize(exception)
      super exception.message
    end
  end

end