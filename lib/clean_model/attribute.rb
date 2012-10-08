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
      elsif value.is_a?(Array) && collection_class.instance_methods.include?(:assign_attributes)
        value.map do |v|
          if v.is_a? collection_class
            v
          else
            obj = collection_class.new
            obj.assign_attributes v
            obj
          end
        end
      else
        value
      end
    end

    def assign_default(model)
      default_value = @options[:default].is_a?(Proc) ? @options[:default].call : @options[:default]
      model.send("#{@name}=", default_value) if default_value && model.respond_to?("#{@name}=")
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