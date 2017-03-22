require 'rhcf_etl/positional_parser'

module RhcfEtl
  class NectarParser
    include RhcfEtl::PositionalParser::ModelDefinition
    include RhcfEtl::PositionalParser::Parsing
    include RhcfEtl::PositionalParser::HashSetup

    options = {
      generate: :devedor,
      encoding: 'iso-8859-1',
      'models' => {
        cobradora: {
          'match' => '\A00',
          relations: {
            devedor: :has_many,
            trailler: :has_one
          },
          fields: {
            'Registro' => 2,
            'Nome' => 50,
            'Endereço' => 80,
            'Bairro' => 30,
            'Cidade' => 30,
            'Estado' => 2,
            'Cep' => 8,
            'Telefone' => 10,
            'Email' => 100,
            'Site' => 150,
            'Data da Geração do Arquivo' => 10,
            'Hora da Geração do Arquivo' => 8,
            'Versão do layout' => 20
          }
        },

        devedor: {
          match: '\A01',

          relations: {
            cobradora: 'belongs_to',
            'titulo' => :has_one,
            'opcoes' =>  { type: :has_many, 'inverse_of' => 'opcao' },
            bens: { 'type' => 'has_many', inverse_of: :bem }
          },
          fields: {
            'Fixo' => 2,
            'Chave ' => 50,
            'Nome' => 60,
            'Endereço' => 160,
            'Bairro' => 50,
            'Cidade' => 50,
            'Estado' => 2,
            'Cep' => 8,
            'Contrato' => 50,
            'Referência' => 50,
            'Conta contrato' => 11,
            'Data Limite' => 10,
            'CPF/CGC' => 14,
            'Valor corrigido' => 12,
            'Data Vencimento' => 10,
            'Barras Digitável' => 58,
            'Barras Impresso' => 44,
            'Valor da Taxa' => 13,
            'Agência Banco' => 6,
            'Cedente Banco' => 20,
            'Nosso Número' => 18,
            'Dígito Nosso Número' => 3,
            'Mercadoria' => 500,
            'Login ' => 10,
            'Senha' => 4,
            'Código Endereço' => 10,
            'Codigo da Carteira' => 10,
            'Descrição da Carteira' => 50,
            'Telefone do Devedor(DDD+Telefone)' => 14,
            'Email 1' => 250,
            'Email 2' => 250,
            'Email 3' => 250,
            'Nome Credor' => 50,
            'Descrição da Campanha' => 50,
            'Descrição da Segmentação' => 50,
            'Descrição da Loja' => 100,
            'Descrição da Classe' => 100,
            'Collector' => 100,
            'Sequencial do Contrato' => 2,
            'Densidade do Contrato' => 5,
            'Data de Ultimo Pagamento' => 10,
            'Valor do Ultimo Pagamento' => 12,
            'Codigo de barras do Contrato' => 55,
            'CORRE_CON' => 7,
            'Data de Inclusão do Contrato' => 10,
            'Codigo do Lote' => 10,
            'Percentual de entrada' => 12,
            'Quantidade de Titulos' => 3,
            'Uso do Banco' => 10,
            'Especie do Documento' => 10,
            'Aceite' => 10,
            'CIP' => 10,
            'Carteira' => 10,
            'Especie' => 10,
            'Cedente' => 600,
            'Email Cedente' => 100,
            'Site Cedente' => 150,
            'Telefone Cedente' => 15,
            'Telefone de Atendimento' => 15
          }
        },
        opcao: {
          match: '\A02',
          relations: {
            devedor: :belongs_to
          },
          fields: {
            'Registro' => 2,
            'Chave' => 50,
            'Entrada  ' => 12,
            'Qde de Parcelas Total' => 2,
            'Valor Parcela  ' => 12,
            'Valor do Saldo ' => 12,
            'Valor Correção ' => 12,
            'Valor de multa ' => 12,
            'Despesa de cobrança' => 12,
            'Multa Contratual ' => 12,
            'Desconto ' => 12,
            'Total' => 12,
            'Valor de Despesa Total ' => 12
          }
        },

        titulo: {
          match: '\A03',
          relations: {
            devedor: :belongs_to
          },
          fields: {
            'Registro' => 2,
            'Chave' => 50,
            'Numero do titulo ' => 25,
            'Vencimento do Titulo ' => 10,
            'Valor do Titulo' => 12,
            'Valor do Titulo2' => 12,
            'Informações do Titulo' => 1500,
            'Data Base Credito' => 10,
            'Data Origem Atraso ' => 10,
            'Valor Origem Atraso' => 12,
            'Valor Juros' => 12,
            'Valor Multa' => 12,
            'Valor Tarifas, ' => 12,
            'Valor IOF' => 12,
            'Valor Anuidade ' => 12,
            'Valor Seguro,' => 12,
            'Valor Principal' => 12,
            'Valor Permanencia' => 12
          }
        },

        bem: {
          match: '\A04',
          relations: {
            devedor: :belongs_to
          },
          fields: {
            'Registro' => 2,
            'Chave' => 50,
            'Descrição' => 1000,
            'Referencia ' => 50,
            'Placa' => 100,
            'Chassi ' => 100,
            'Marca' => 300,
            'Modelo ' => 100,
            'Ano do Modelo' => 4,
            'Ano de Fabricação' => 4,
            'Cor' => 50,
            'Valor' => 12
          }
        },

        trailler: {
          match: '\A09',
          relations: {
            cobradora: :belongs_to
          },
          fields: {
            'Registro' => 2,
            'Qtd Total de linhas' => 12,
            'Qtd de registro 01 ' => 12,
            'Qtd de registro 02 ' => 12,
            'Qtd de registro 03 ' => 12,
            'Qtd de registro 04 ' => 12
          }
        }
      }

    }
    hash_setup(options)
  end
end
