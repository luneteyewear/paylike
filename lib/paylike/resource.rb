require 'ostruct'
require 'http/rest_client'

module Paylike
  # Base resource class
  class Resource < OpenStruct
    extend HTTP::RestClient::DSL
    extend HTTP::RestClient::CRUD

    # Resource collection finder, uses the default limit
    #
    # @param params [Hash] URI parameters to pass to the endpoint.
    # @return [Array] of [Paylike::Resource] instances
    def self.all(params = {})
      params[:limit] ||= 100
      super(params)
    end

    # Resource finder
    #
    # @param id [String] resource indentifier
    # @return [Paylike::Resource] instance
    def self.find(id, params = {})
      objectify(request(:get, uri_sans_merchant_id(id), params: params))
    end

    # Like `uri`, but removes any merchant ID from the path
    #
    # @return [String]
    def self.uri_sans_merchant_id(*args)
      uri(*args).to_s.gsub(%r{\/merchants\/[\w]+}, '')
    end

    # Custom response parser to extract successful payloads
    #
    # @param response [HTTP::Response] object
    # @return [Object] on parsable responses
    def self.parse_response(response)
      parsed = super

      return parsed.values.first if parsed.is_a?(Hash) && parsed.size == 1

      return parsed.first if parsed.is_a?(Array) && parsed.size == 1

      parsed
    end

    # Extracts the error message from the response
    #
    # @param response [HTTP::Response] the server response
    # @param parsed_response [Object] the parsed server response
    #
    # @return [String]
    def self.extract_error(_, parsed_response)
      parsed_response.delete('message') if parsed_response.respond_to?(:delete)
    end
  end
end
