# frozen_string_literal: true

require 'cgi'
require 'dotenv'
require 'logger'
require 'roda'
require 'sequel'
require 'tilt'

Dotenv.load

module Ponyx
  DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
  DB.loggers << Logger.new(STDOUT)

  def self.create_table
    DB.create_table(:onix) do
      primary_key :id
      column :uri, String
      column :message, :xml
    end
  end

  def self.create_index
    DB.execute(<<~SQL)
      create index product_record_reference_index
        on onix
        using gin (((xpath('ns:ONIXMessage/ns:Product/ns:RecordReference/text()', message,
                             ARRAY [ARRAY ['ns', 'http://ns.editeur.org/onix/3.0/reference']])) :: text []));
    SQL
  end

  def self.import_data(path: ENV.fetch('ONIX_DATA_DIR'))
    Dir[path].each do |file_name|
      DB[:onix].insert(uri: file_name, message: File.read(file_name))
    end
  end

  class Repository
    attr_reader :db, :root

    def initialize(db: DB, root: :onix)
      @db = db
      @root = db[root]
    end

    # @param reference [String] Record reference
    def by_reference(reference)
      nsmap = %(ARRAY[ARRAY['ns', 'http://ns.editeur.org/onix/3.0/reference']])
      xpath_product = %('ns:ONIXMessage/ns:Product[ns:RecordReference="#{reference}"]')
      xpath_sent_at = %('ns:ONIXMessage/ns:Header/ns:SentDateTime/text()')
      root
        .select(
          :id,
          Sequel.lit("(xpath(#{xpath_sent_at}, message, #{nsmap}))[1]::text as sent_at"),
          Sequel.lit("(xpath(#{xpath_product}, message, #{nsmap}))[1]::text as product")
        )
        .where(Sequel.lit(%((xpath('ns:ONIXMessage/ns:Product/ns:RecordReference/text()', message, #{nsmap})) :: text [] @> array['#{reference}'])))
    end
  end

  class App < ::Roda
    plugin :multi_run
    plugin :public

    plugin :render, engine: 'erb', views: 'views'

    opts[:root] = File.dirname(__FILE__)

    route do |routes|
      routes.root do
        view('index', locals: { items: [] })
      end

      routes.post '' do
        reference = routes.params['reference']
        items = reference ? repository.by_reference(reference) : []
        view('index', locals: { items: items })
      end
    end

    def repository
      @repository ||= Repository.new
    end
  end
end
