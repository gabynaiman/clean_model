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

end