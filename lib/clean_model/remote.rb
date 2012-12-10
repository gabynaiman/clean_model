module CleanModel
  module Remote

    def self.included(base)
      base.send :include, Persistent
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods

      def connection(connection=nil)
        connection ? @connection = WebClient::Connection.new(connection) : @connection
      end

    end

    module InstanceMethods

      def save
        return false unless valid?
        begin
          response = new_record? ? create : update
          if response.success?
            save_success(response)
          else
            save_fail(response)
          end
        rescue WebClient::Error => ex
          errors[:base] = ex.message
        end
        errors.empty?
      end

      def destroy
        return true if new_record?
        begin
          response = delete
          unless response.success?
            errors[:base] = response.content_type == 'application/json' ? response.body : "#{response.code} - Unexpected error"
          end
        rescue WebClient::Error => ex
          errors[:base] = ex.message
        end
        errors.empty?
      end

      private

      def connection
        self.class.connection
      end

      def wrapped_attributes(options={})
        exceptions = options[:except] ? [options[:except]].flatten.map(&:to_sym) : []
        attributes.reject { |k, v| v.nil? || exceptions.include?(k) }.inject({}) { |h, (k, v)| h["#{options[:wrapper] || self.class.to_s.demodulize.underscore}[#{k}]"] = v; h }
      end

      def save_success(response)
        assign_attributes JSON.parse(response.body) if response.body
      end

      def save_fail(response)
        if response.code.to_i == 422 #:unprocessable_entity
          JSON.parse(response.body).each do |attribute, messages|
            messages.each { |m| errors[attribute.to_sym] << m }
          end
        else
          errors[:base] = response.content_type == 'application/json' ? response.body : "#{response.code} - Unexpected error"
        end
      end

    end

  end
end