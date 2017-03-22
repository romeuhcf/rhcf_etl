require 'spec_helper'
require 'csv'
module RhcfEtl
  class CsvParser
    def initialize(options = {})
      @options = options
    end

    def parse(file, &block)
      CSV.foreach(file, @options) do |me|
        yield me.to_hash
      end
    end

  end
end

describe RhcfEtl::CsvParser do
  subject {described_class.new(options)}
  let(:row) do
    row = nil

    subject.parse(file) do |_row|
      row = _row
      break
    end

    row
  end

  describe "nice little file" do
    let(:options) {{ col_sep: ';', headers: true }}
    let(:file) {fixture_file_by_content("a;b;c\n1;;3")}
    it {expect(row).to eq( {'a' => '1', 'b' => nil, 'c' => '3'}) }
  end

end
