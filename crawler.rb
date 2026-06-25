# frozen_string_literal: true

require 'relaton/nist/data_fetcher'

FileUtils.rm_rf('data')
FileUtils.rm Dir.glob('index*')

Relaton::Nist::DataFetcher.fetch # output:'dir'

index = Relaton::Index.find_or_create :nist, file: "#{Relaton::Nist::INDEXFILE}.yaml",
                                      pubid_class: ::Pubid::Nist::Identifier

# Index static files by a parsed pubid object (never a raw String): the index
# sorts entries via `get_id_number`, which calls `.number` on the id, so a
# String crashes the save. Skip entries whose docid is not a parseable pubid.
Dir["static/*.yaml"].each do |file|
  bib = Relaton::Nist::Item.from_yaml(File.read(file, encoding: "UTF-8"))
  id = bib.docidentifier.find(&:primary) || bib.docidentifier.first
  pid = ::Pubid::Nist::Identifier.parse(id.content)
  index.add_or_update pid, file
rescue StandardError => e
  warn "Skipping static `#{file}` (#{id&.content}): #{e.message}"
end

index.save
