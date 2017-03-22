require 'rhcf_etl/positional_parser'

module RhcfEtl
  module ConfigurablePositionalParser
    def self.new(options)
      Class.new do
        include RhcfEtl::PositionalParser::ModelDefinition
        include RhcfEtl::PositionalParser::Parsing
        include RhcfEtl::PositionalParser::HashSetup
        hash_setup options
      end.new
    end
  end
end
