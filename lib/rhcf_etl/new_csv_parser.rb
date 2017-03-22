require 'csv'
require 'active_support/core_ext/object/blank'

#require 'ext/file_gets_recode_refinement'
#using FileGetsTransliterateRefinement

module  RhcfEtl
  class NewCsvParser
    def initialize(options = {})
      @options = options
      @options[:encoding] ||= 'windows-1252'
    end

    def parse(file)
      items = []

      headers = nil
      encoding = @options[:encoding]

      File.open(file, "r:#{encoding}") do |fd|
        # TODO skip n lines

        if @options[:headers] == true
          line = get_full_line(fd)
          return items unless line
          headers = parse_line(line)
        elsif @options[:headers].is_a? Array
          headers = @options[:headers]
        end

        while line = get_full_line(fd)
          vars = parse_line(line)
          next if vars.blank?

          if headers
            vars = Hash[headers.zip(vars)]
          end

          if block_given?
            yield vars
          else
            items << vars
          end
        end
      end

      items
    end

    def get_full_line(fd)
      tokens = []
      token = fd.gets
      return nil unless token
      tokens << token
      quote_count = token.count('"')

      while quote_count.odd?
        token = fd.gets
        break if token.nil?
        quote_count += token.count('"')
        tokens << token
      end

      return tokens.join
    end

    def parse_line(line)
      CSV.parse_line(line.strip, csv_options)
    end

    def csv_options
      col_sep = @options[:col_sep] || ';'
      @csv_options ||= { col_sep: col_sep }
    end
  end
end
