# frozen_string_literal: true

require 'relaton/nist/data_fetcher'

FileUtils.rm_rf('data')
FileUtils.rm Dir.glob('index*')

Relaton::Nist::DataFetcher.fetch # output:'dir'

index = Relaton::Index.find_or_create :nist, file: "#{Relaton::Nist::INDEXFILE}.yaml"

Dir["static/*.yaml"].each do |file|
  bib = Relaton::Nist::Item.from_yaml(File.read(file, encoding: "UTF-8"))
  index.add_or_update bib.docidentifier[0].content, file
end

index.save
