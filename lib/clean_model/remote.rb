module CleanModel
  module Remote

    def self.included(base)
      base.send :include, Persistent
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods

      def connection(connection=nil)
        connection ? @connection = connection : @connection
      end

      def http
        WebClient::Base.new(connection)
      end

      def http_get(path, data=nil, headers={})
        begin
          response = http.get(path, data, headers)
          if response.is_a?(Net::HTTPSuccess)
            block_given? ? yield(response) : response
          else
            raise InvalidResponse.new(response)
          end
        rescue WebClient::Error => ex
          raise ConnectionFail.new(ex)
        end
      end

    end

    module InstanceMethods

      def http
        self.class.http
      end

      def http_get(path, data={}, &block)
        self.class.http_get(path, data, &block)
      end

      def wrapped_attributes(options={})
        exceptions = options[:except] ? [options[:except]].flatten.map(&:to_sym) : []
        attributes.reject { |k, v| v.nil? || exceptions.include?(k) }.inject({}) { |h, (k, v)| h["#{options[:wrapper] || self.class.to_s.demodulize.underscore}[#{k}]"] = v; h }
      end

      def save
        return false unless valid?
        begin
          response = new_record? ? create : update
          if response.is_a?(Net::HTTPSuccess)
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
          unless response.is_a?(Net::HTTPSuccess)
            errors[:base] = response.content_type == 'application/json' ? response.body : "#{response.code} - Unexpected error"
          end
        rescue WebClient::Error => ex
          errors[:base] = ex.message
        end
        errors.empty?
      end

      private

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