require 'json'
require 'paylike/resource'
require 'paylike/gateway'
require 'paylike/version'

# Paylike HTTP API Client
module Paylike
  # The 3D Secure error code
  THREE_D_SECURE_ERROR_CODE = 30
  # The 3D Secure callback URI
  THREE_D_SECURE_CALLBACK_URI = 'https://gateway.paylike.io/acs-response'.freeze

  # Validates and extracts 3D Secure related data from an error response
  #
  # @param error [ApiClient::ResponseError] the response error to extract from
  # @param uid [String] the unique identifier to use as the 3D Secure `MD` value
  #
  # @return [Hash] on valid 3D Secure response errors
  def self.extract_threedsecure_data(error, uid)
    resp_data = error.response_data

    if resp_data.nil? || resp_data['code'].to_i != THREE_D_SECURE_ERROR_CODE
      return
    end

    {
      threedsecure_url: resp_data['tds']['url'],
      threedsecure_data: {
        MD: uid,
        TermUrl: THREE_D_SECURE_CALLBACK_URI,
        PaReq: resp_data['tds']['pareq']
      }
    }
  end

  # Base endpoint resources class
  class Base < Resource
    endpoint 'https://api.paylike.io'
    basic_auth user: '', pass: ENV['PAYLIKE_KEY']
    content_type 'application/json'
    accept 'application/json'
  end

  # Transactions endpoint resource
  class Transaction < Base
    path "/merchants/#{ENV['PAYLIKE_MERCHANT_ID']}/transactions"

    # Delegate the resource creation to the gateway, but maintain the rest
    #
    # @return [Paylike::Transaction] instance
    def self.create(*args)
      gw_tran = Gateway::Transaction.create(*args)
      find(gw_tran.id)
    end

    # Refunds helper
    #
    # @return [NilClass]
    def void
      voids_uri = self.class.uri_sans_merchant_id(id, :voids)
      data = self.class.request(:post, voids_uri, json: { amount: amount })
      symbolized = JSON.parse(data.to_json, symbolize_names: true)
      marshal_load(symbolized) if data.is_a?(Hash)
    end

    # Refunds helper
    #
    # @param params [Hash] the `amount` and the `descriptor`.
    # @return [NilClass]
    def refund(params)
      refunds_uri = self.class.uri_sans_merchant_id(id, :refunds)
      data = self.class.request(:post, refunds_uri, json: params)
      symbolized = JSON.parse(data.to_json, symbolize_names: true)
      marshal_load(symbolized) if data.is_a?(Hash)
    end

    # Capture helper
    #
    # @param params [Hash] the `amount` and the `descriptor`.
    # @return [NilClass]
    def capture(params)
      captures_uri = self.class.uri_sans_merchant_id(id, :captures)
      data = self.class.request(:post, captures_uri, json: params)
      symbolized = JSON.parse(data.to_json, symbolize_names: true)
      marshal_load(symbolized) if data.is_a?(Hash)
    end
  end

  # Users endpoint resource
  class User < Base
    path "/merchants/#{ENV['PAYLIKE_MERCHANT_ID']}/users"
  end

  # Applications endpoint resource
  class App < Base
    path "/merchants/#{ENV['PAYLIKE_MERCHANT_ID']}/apps"
  end

  # Cards endpoint resource
  class Card < Base
    path "/merchants/#{ENV['PAYLIKE_MERCHANT_ID']}/cards"
  end

  # Lines endpoint resource
  class Line < Base
    path "/merchants/#{ENV['PAYLIKE_MERCHANT_ID']}/lines"
  end
end
