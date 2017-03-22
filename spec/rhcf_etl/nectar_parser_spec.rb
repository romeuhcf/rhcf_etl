require 'spec_helper'
require 'rhcf_etl/nectar_parser'

module RhcfEtl
  describe NectarParser do
    let(:file) { fixture_file('nectar/sample.txt') }
    it { is_expected.to be_instance_of described_class }
    it { expect(subject.parse(file)).to be_instance_of Array }
    it { expect(subject.parse(file).size).to eq 21 }

    it do
      subject.parse(file) do |instance|
        expect(instance.to_hash).to be_instance_of CaseInsensitiveHash
      end
    end

    it do
      subject.parse(file) do |instance|
        # expect(instance).to be_instance_of PositionalParser::ModelDefinition::Instance
        # expected = ["Registro", "Chave", "Nome", 'opcoes', 'titulo', 'bens']
        expect(instance.to_hash['opcoes'].count).to eq 3
        expect(instance.to_hash['opcoes'].first['Chave']).to eq '06860463406-1'
        expect(instance.to_hash['titulo']).to be_instance_of CaseInsensitiveHash
        expect(instance.to_hash['cobradora']).to be_instance_of CaseInsensitiveHash

        expect(instance.to_hash['Nome']).to eq 'Cizdt Mybyiz Pitiytd'
        expect(instance.to_hash['Email 1']).to eq 'jxhn.yzybh@bzdyz.cxz'
        expect(instance.to_hash['Email_1']).to eq 'jxhn.yzybh@bzdyz.cxz'
        expect(instance.to_hash['email_1']).to eq 'jxhn.yzybh@bzdyz.cxz'
        break
      end
    end

    # TODO: test duplicate field
    # TODO check existing formatter
  end
end
