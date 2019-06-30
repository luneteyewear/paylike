require 'spec_helper'

RSpec.describe Paylike do
  let(:error_message) { FFaker::Lorem.phrase }
  let(:error_code) { Paylike::THREE_D_SECURE_ERROR_CODE }
  let(:acs_url) { FFaker::Internet.http_url }
  let(:acs_pareq) { FFaker::Internet.password }
  let(:error_payload) do
    {
      code: error_code,
      message: error_message,
      client: true,
      merchant: false,
      tds: { url: acs_url, pareq: acs_pareq }.transform_keys(&:to_s)
    }.transform_keys(&:to_s)
  end
  let(:response) do
    HTTP::Response.new(
      status: 422,
      version: '2',
      body: error_payload.to_json,
      headers: { HTTP::Headers::CONTENT_TYPE => 'application/json' }
    )
  end

  context Paylike::Resource do
    context '#handle_response' do
      it 'raises a response error' do
        expect { Paylike::Resource.handle_response(response) }
          .to raise_error do |err|
            expect(err).to be_a(HTTP::RestClient::ResponseError)
            expect(err.message).to eq(error_message)
            expect(err.response_data)
              .to eq(error_payload.keep_if { |k, _| k.to_s != 'message' })
          end
      end
    end
  end

  context '#extract_threedsecure_data' do
    let(:uid) { FFaker::Internet.password }

    context 'when not a 3D Secure error response' do
      let(:error_code) { rand(40..50) }

      it do
        expect { Paylike::Resource.handle_response(response) }
          .to raise_error do |err|
            extracted = described_class.extract_threedsecure_data(err, nil)
            expect(extracted).to be_nil
          end
      end
    end

    it do
      expect { Paylike::Resource.handle_response(response) }
        .to raise_error do |err|
          extracted = described_class.extract_threedsecure_data(err, uid)

          expect(extracted).to eq(
            threedsecure_url: acs_url,
            threedsecure_data: {
              MD: uid,
              PaReq: acs_pareq,
              TermUrl: Paylike::THREE_D_SECURE_CALLBACK_URI
            }
          )
        end
    end
  end

  describe Paylike::Transaction do
    let(:cassette_name) do |subjekt|
      subjekt.full_description.downcase.strip.gsub(/[^a-z]+/, '-')
    end

    before { VCR.insert_cassette(cassette_name) }

    after { VCR.eject_cassette(cassette_name) }

    context '#all' do
      it do
        all = Paylike::Transaction.all(limit: 2)
        expect(all.size).to eq(2)
        expect(all.first.class).to eq(Paylike::Transaction)
      end
    end

    context '#create' do
      let(:trans_data) do
        {
          currency: 'EUR',
          amount: 1000,
          card: {
            number: '4100000000000000',
            code: '123',
            expiry: {
              month: '08',
              year: '2020'
            }
          }
        }
      end

      it 'creates captures and refunds' do
        trans = Paylike::Transaction.create(trans_data)
        expect(trans.id).not_to be_nil
        expect(trans.amount).to eq(trans_data[:amount])
        expect(trans.currency).to eq(trans_data[:currency])

        trans.capture(amount: trans_data[:amount] / 2)
        expect(trans.amount).to eq(trans_data[:amount])
        expect(trans.capturedAmount).to eq(trans_data[:amount] / 2)

        trans.refund(amount: trans_data[:amount] / 3)
        expect(trans.amount).to eq(trans_data[:amount])
        expect(trans.refundedAmount).to eq(trans_data[:amount] / 3)

        expect(trans.successful).to eq(true)
      end

      it 'creates and voids' do
        trans = Paylike::Transaction.create(trans_data)
        expect(trans.id).not_to be_nil
        expect(trans.amount).to eq(trans_data[:amount])
        expect(trans.currency).to eq(trans_data[:currency])

        trans.void

        expect(trans.amount).to eq(trans_data[:amount])
        expect(trans.voidedAmount).to eq(trans_data[:amount])
        expect(trans.successful).to eq(true)
      end
    end
  end
end
