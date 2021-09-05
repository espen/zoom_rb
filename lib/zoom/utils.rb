# frozen_string_literal: true

module Zoom
  class Utils
    class << self
      def argument_error(name)
        name ? ArgumentError.new("You must provide #{name}") : ArgumentError.new
      end

      def exclude_argument_error(name)
        name ? ArgumentError.new("Unrecognized parameter #{name}") : ArgumentError.new
      end

      def raise_if_error!(response, http_code=200)
        return response unless response&.key?('code')

        code = response['code']

        raise AuthenticationError, build_error(response) if code == 124
        error_hash = build_error(response)
        raise Error.new(error_hash, error_hash) if code >= 300 || http_code >= 400
      end

      def build_error(response)
        error_hash = { base: response['message']}
        error_hash[response['message']] = response['errors'] if response['errors']
        error_hash
      end

      def parse_response(http_response)
        raise_if_error!(http_response.parsed_response, http_response.code) || http_response.code
      end

      def extract_options!(array)
        array.last.is_a?(::Hash) ? array.pop : {}
      end

      def validate_password(password)
        password_regex = /\A[a-zA-Z0-9@-_*]{0,10}\z/
        raise(Error , 'Invalid Password') unless password[password_regex].nil?
      end

      def process_datetime_params!(params, options)
        params = [params] unless params.is_a? Array
        params.each do |param|
          if options[param] && options[param].kind_of?(Time)
            options[param] = options[param].strftime('%FT%TZ')
          end
        end
        options
      end
    end
  end
end
