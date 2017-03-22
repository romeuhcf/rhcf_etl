require 'rhcf_etl/positional_parser'

module RhcfEtl
  class NectarParser
    include RhcfEtl::PositionalParser::ModelDefinition
    include RhcfEtl::PositionalParser::Parsing
    generate :devedor
    encoding 'iso-8859-1'

    model :cobradora, /\A00/ do
      has_many :devedor
      has_one :trailler
      field 'Registro', 2
      field 'Nome ', 50
      field 'Endereço ', 80
      field 'Bairro ', 30
      field 'Cidade ', 30
      field 'Estado ', 2
      field 'Cep', 8
      field 'Telefone ', 10
      field 'Email', 100
      field 'Site ', 150
      field 'Data da Geração do Arquivo ', 10
      field 'Hora da Geração do Arquivo ', 8
      field 'Versão do layout ', 20
    end

    model :devedor, /\A01/ do
      belongs_to :cobradora
      has_many :opcoes, inverse_of: :opcao
      has_one :titulo
      has_many :bens, inverse_of: :bem
      field 'Fixo', 2
      field 'Chave ', 50
      field 'Nome', 60
      field 'Endereço', 160
      field 'Bairro', 50
      field 'Cidade', 50
      field 'Estado', 2
      field 'Cep', 8
      field 'Contrato', 50
      field 'Referência', 50
      field 'Conta contrato', 11
      field 'Data Limite', 10
      field 'CPF/CGC', 14
      field 'Valor corrigido', 12
      field 'Data Vencimento', 10
      field 'Barras Digitável', 58
      field 'Barras Impresso', 44
      field 'Valor da Taxa', 13
      field 'Agência Banco', 6
      field 'Cedente Banco', 20
      field 'Nosso Número', 18
      field 'Dígito Nosso Número', 3
      field 'Mercadoria', 500
      field 'Login ', 10
      field 'Senha', 4
      field 'Código Endereço', 10
      field 'Codigo da Carteira', 10
      field 'Descrição da Carteira', 50
      field 'Telefone do Devedor(DDD+Telefone)', 14
      field 'Email 1', 250
      field 'Email 2', 250
      field 'Email 3', 250
      field 'Nome Credor', 50
      field 'Descrição da Campanha', 50
      field 'Descrição da Segmentação', 50
      field 'Descrição da Loja', 100
      field 'Descrição da Classe', 100
      field 'Collector', 100
      field 'Sequencial do Contrato', 2
      field 'Densidade do Contrato', 5
      field 'Data de Ultimo Pagamento', 10
      field 'Valor do Ultimo Pagamento', 12
      field 'Codigo de barras do Contrato', 55
      field 'CORRE_CON', 7
      field 'Data de Inclusão do Contrato', 10
      field 'Codigo do Lote', 10
      field 'Percentual de entrada', 12
      field 'Quantidade de Titulos', 3
      field 'Uso do Banco', 10
      field 'Especie do Documento', 10
      field 'Aceite', 10
      field 'CIP', 10
      field 'Carteira', 10
      field 'Especie', 10
      field 'Cedente', 600
      field 'Email Cedente', 100
      field 'Site Cedente', 150
      field 'Telefone Cedente', 15
      field 'Telefone de Atendimento', 15
    end

    model :opcao, /\A02/ do
      belongs_to :devedor
      field 'Registro', 2
      field 'Chave', 50
      field 'Entrada  ', 12
      field 'Qde de Parcelas Total', 2
      field 'Valor Parcela  ', 12
      field 'Valor do Saldo ', 12
      field 'Valor Correção ', 12
      field 'Valor de multa ', 12
      field 'Despesa de cobrança', 12
      field 'Multa Contratual ', 12
      field 'Desconto ', 12
      field 'Total', 12
      field 'Valor de Despesa Total ', 12
    end

    model :titulo, /\A03/ do
      belongs_to :devedor
      field 'Registro', 2
      field 'Chave', 50
      field 'Numero do titulo ', 25
      field 'Vencimento do Titulo ', 10
      field 'Valor do Titulo', 12
      field 'Valor do Titulo2', 12
      field 'Informações do Titulo', 1500
      field 'Data Base Credito', 10
      field 'Data Origem Atraso ', 10
      field 'Valor Origem Atraso', 12
      field 'Valor Juros', 12
      field 'Valor Multa', 12
      field 'Valor Tarifas, ', 12
      field 'Valor IOF', 12
      field 'Valor Anuidade ', 12
      field 'Valor Seguro,', 12
      field 'Valor Principal', 12
      field 'Valor Permanencia', 12
    end

    model :bem, /\A04/ do
      belongs_to :devedor
      field 'Registro', 2
      field 'Chave', 50
      field 'Descrição', 1000
      field 'Referencia ', 50
      field 'Placa', 100
      field 'Chassi ', 100
      field 'Marca', 300
      field 'Modelo ', 100
      field 'Ano do Modelo', 4
      field 'Ano de Fabricação', 4
      field 'Cor', 50
      field 'Valor', 12
    end

    model :trailler, /\A09/ do
      belongs_to :cobradora
      field 'Registro', 2
      field 'Qtd Total de linhas', 12
      field 'Qtd de registro 01 ', 12
      field 'Qtd de registro 02 ', 12
      field 'Qtd de registro 03 ', 12
      field 'Qtd de registro 04 ', 12
    end
  end
end
