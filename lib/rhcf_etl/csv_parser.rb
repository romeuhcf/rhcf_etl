require 'csv'
require 'active_support/core_ext/object/blank'

#require 'ext/file_gets_recode_refinement'
#using FileGetsTransliterateRefinement

module  RhcfEtl
  class CsvParser
    def initialize(options = {})
      default_options = { encoding: 'windows-1252' }
      @options = default_options.merge(options)
    end

    def parse(file)
      CSV.foreach(file, @options) do |row|
        yield @options[:headers] ? row.to_hash : row
      end
    end
  end
end
