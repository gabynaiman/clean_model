module CleanModel
  module Persistent

    def self.included(base)
      base.send :include, Base
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
      base.send :include, ActiveModel::Conversion

      base.attribute :id
    end

    module ClassMethods

      def create(attributes={})
        begin
          create! attributes
        rescue
          nil
        end
      end

      def create!(attributes={})
        model = new attributes
        model.save!
        model
      end

    end

    module InstanceMethods

      def new_record?
        id.nil?
      end

      def persisted?
        !new_record?
      end

      def save!
        raise errors.full_messages.join("\n") unless save
      end

      def save
        return false unless valid?
        new_record? ? create : update
      end

      def update_attributes(attributes)
        assign_attributes attributes
        save
      end

      def destroy
        raise UndefinedPersistenceMethod.new(self.class, :destroy)
      end

      private

      def create
        raise UndefinedPersistenceMethod.new(self.class, :create)
      end

      def update
        raise UndefinedPersistenceMethod.new(self.class, :update)
      end

    end

  end
end