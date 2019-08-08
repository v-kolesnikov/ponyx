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

RSpec.describe Ponyx::Repository, '#by_reference' do
  subject(:repo) { described_class.new }

  before do
    Ponyx.import_data(path: 'spec/fixtures/onix/*.xml')
  end

  after do
    repo.root.delete
  end

  it 'restrics rows by XPath and array inclusion' do
    aggregate_failures do
      expect(repo.by_reference('1').to_a.map { |sent_at:, **| sent_at })
        .to match_array %w[20190807T090000Z 20190809T090000Z]
      expect(repo.by_reference('2').to_a.map { |sent_at:, **| sent_at })
        .to match_array %w[20190807T090000Z 20190808T090000Z]
      expect(repo.by_reference('3').to_a.map { |sent_at:, **| sent_at })
        .to match_array %w[20190809T090000Z]
    end
  end

  it 'project requested product only' do
    result = repo.by_reference('1').map { |product:, **| product }
    expected = [
      <<~MESSAGE.strip,
        <Product xmlns="http://ns.editeur.org/onix/3.0/reference">
          <RecordReference>1</RecordReference>
          <NotificationType>03</NotificationType>
        </Product>
      MESSAGE
      <<~MESSAGE.strip
        <Product xmlns="http://ns.editeur.org/onix/3.0/reference">
          <RecordReference>1</RecordReference>
          <NotificationType>04</NotificationType>
        </Product>
      MESSAGE
    ]
    expect(result).to match_array(expected)
  end
end
