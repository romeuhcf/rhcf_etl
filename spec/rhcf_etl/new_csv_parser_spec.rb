require 'spec_helper'
require 'rhcf_etl/new_csv_parser'

describe RhcfEtl::NewCsvParser do
  subject { RhcfEtl::NewCsvParser.new(col_sep: ';') }
  let(:row) do
    row = nil
    subject.parse(file) { |i| row = i ;break }
    row
  end

  context "simple" do
    let(:file) { fixture_file_by_content("a;b;c") }
    it { expect(row).to eq(['a', 'b', 'c']) }
  end

  context "with headers on first line " do
    subject { RhcfEtl::NewCsvParser.new(col_sep: ';', headers: true) }
    let(:file) { fixture_file_by_content("x;y;z\na;b;c") }
    it { expect(row).to eq('x' => 'a', 'y' => 'b', 'z' => 'c') }
  end

  context "with used defined headers" do
    subject { RhcfEtl::NewCsvParser.new(col_sep: ';', headers: ['x', 'y', 'z', 'o']) }
    let(:file) { fixture_file_by_content("a;b;c") }
    it { expect(row).to eq('x' => 'a', 'y' => 'b', 'z' => 'c', 'o' => nil) }
  end

  context "with line break" do
    let(:file) { fixture_file_by_content("\"hello\nworld\";ok") }

    it { expect(row[0]).to eq "hello\nworld" }
    it { expect(row[1]).to eq "ok" }
  end

  xcontext "with broken quotes" do
    let(:file) { fixture_file_by_content("\"hello\nworld;ok") }

    it { expect(row[0]).to eq "hello\nworld" }
    it { expect(row[1]).to eq "ok" }
  end

  xcontext "with whole line quoted" do
    let(:file) { fixture_file_by_content("'hello\nworld;ok'") }

    it { expect(row[0]).to eq "hello\nworld" }
    it { expect(row[1]).to eq "ok" }
  end

  context "one column" do
    let(:file) { fixture_file_by_content("foo") }
    it { expect(row).to eq(["foo"]) }
    it { expect { subject.parse(file) { |i| } }.to_not raise_error }
  end
end
