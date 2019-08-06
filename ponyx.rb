# frozen_string_literal: true

require 'dotenv'
require 'roda'
require 'sequel'

require 'pry'

Dotenv.load

module Ponyx
  DB = Sequel.connect(ENV.fetch('PONYX_DATABASE_URL'))

  def self.create_table
    DB.create_table(:onix) do
      primary_key :id
      column :uri, String
      column :message, :xml
    end
  end

  def self.import_data
    files = Dir[ENV.fetch('PONYX_ONIX_DATA_DIR')]
    files.each do |file_name|
      File.open(file_name) do |file|
        DB[:onix].insert(uri: file_name, message: file.read)
      end
    end
  end

  class App < ::Roda
    plugin :multi_run
    plugin :public

    opts[:root] = File.dirname(__FILE__)

    route do |routes|
      routes.root do
        'Ponyx'
      end
    end
  end
end
