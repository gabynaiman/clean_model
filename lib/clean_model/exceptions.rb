module CleanModel

  class Error < StandardError
  end

  class InvalidTypeAssignment < Error

    def initialize(attribute, value)
      @attribute = attribute
      @value = value
    end

    def message
      "#{@value} is not valid for #{@attribute}"
    end

  end

end