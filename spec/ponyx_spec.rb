# frozen_string_literal: true

require 'rack/test'

RSpec.describe Ponyx::App do
  include Rack::Test::Methods

  subject(:app) { described_class.app }

  describe 'GET /', type: :request do
    subject(:response) { get '/' }

    it { expect(response.status).to be 200 }
  end
end
