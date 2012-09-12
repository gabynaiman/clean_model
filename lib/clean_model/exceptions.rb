module CleanModel

  class Error < StandardError
  end

  class InvalidTypeAssignment < Error
    attr_reader :attrubute, :value

    def initialize(attribute, value)
      @attribute = attribute
      @value = value
    end

    def message
      "#{@value} is not valid for #{@attribute}"
    end

  end

  class UndefinedPersistenceMethod < Error
    attr_reader :klass, :method

    def initialize(klass, method)
      @klass = klass
      @method = method
    end

    def message
      "#{@klass} must define method [#{@method}]"
    end

  end

end