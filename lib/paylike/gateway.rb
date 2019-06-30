require 'paylike/resource'

module Paylike
  # Gateway endpoint resources
  #
  # See: https://github.com/paylike/api-docs/blob/master/gateway.md#gateway-api-reference
  module Gateway
    # Base Gateway endpoint resources class
    class Base < Resource
      endpoint('https://gateway.paylike.io')
      content_type 'application/json'
      accept 'application/json'

      # Customized resource creation helper to enable key-based authentication
      #
      # @return [Paylike::Gateway::Resource] instance
      def self.create(params = {})
        params[:key] = ENV['PAYLIKE_PUBLIC_KEY']
        super(params)
      end
    end

    # Transaction endpoint resource (used only for creation)
    #
    # See: https://github.com/paylike/api-docs/blob/master/gateway.md#create-a-payment
    class Transaction < Base
      path '/transactions'
    end

    # Card endpoint resource (used only for creation)
    #
    # See: https://github.com/paylike/api-docs/blob/master/gateway.md#tokenize-a-card-for-later-use
    class Card < Base
      path '/cards'
    end
  end
end
