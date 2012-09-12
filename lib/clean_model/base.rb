module CleanModel
  module Base

    def self.included(base)
      base.send :extend, ActiveModel::Translation
      base.send :include, ActiveModel::Validations

      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods

      def attribute(name, options={})
        attr = Attribute.new(name, options)
        attributes << attr

        define_method name do
          instance_variable_get "@#{name}"
        end

        define_method "#{name}=" do |value|
          value = attr.transform(value)
          attr.validate!(value)
          instance_variable_set "@#{name}", value
        end
      end

      def attributes
        @attributes ||= []
      end

      def attribute_names
        attributes.map(&:name)
      end

    end

    module InstanceMethods

      def initialize(attributes={})
        if block_given?
          yield(self)
        else
          assign_attributes attributes
        end
      end

      def assign_attributes(attributes)
        return nil unless attributes
        attributes.each do |name, value|
          send("#{name}=", value) if respond_to?("#{name}=")
        end
      end

      def attributes
        Hash[self.class.attribute_names.map { |a| [a, send(a)] }]
      end

    end

  end
end