module CleanModel
  class Attribute
    attr_reader :name, :options

    def initialize(name, options={})
      @name = symbolize(name)
      @options = options
    end

    def validate!(value)
      raise InvalidTypeAssignment.new(name, value) unless value.is_a? klass
    end

    def transform(value)
      if @options[:transformation]
        @options[:transformation].call(value)
      elsif value.is_a?(Hash) && klass.new.respond_to?(:assign_attributes)
        obj = klass.new
        obj.assign_attributes value
        obj
      elsif value.is_a?(Array) && collection_class.new.respond_to?(:assign_attributes)
        value.map do |v|
          obj = collection_class.new
          obj.assign_attributes v
          obj
        end
      else
        value
      end
    end

    private

    def klass
      @options[:class_name].to_s.classify.constantize
    end

    def collection_class
      @options[:collection].to_s.classify.constantize
    end

    def symbolize(text)
      text.is_a?(String) ? text.to_s.underscore.parameterize('_').to_sym : text
    end

  end
end