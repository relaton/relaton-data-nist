require "relaton_nist"

FileUtils.rm_rf('data')
FileUtils.rm Dir.glob('index*')

RelatonNist::DataFetcher.fetch(output: "data", format: "yaml")
