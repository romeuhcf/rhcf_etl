require 'active_support/concern'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/class/attribute_accessors'
require 'case_insensitive_hash'

module RhcfEtl
  module PositionalParser
    module HashSetup
      extend ActiveSupport::Concern

      class_methods do
        def hash_setup(options)
          options = options.deep_symbolize_keys
          encoding options[:encoding]
          generate options[:generate]

          options[:models].each do |mname, mdef|
            match = Regexp.new(mdef[:match])
            model mname, match do
              mdef[:relations].each do |rname, rdef|
                rtype = rdef
                ropts = {}

                if rdef.is_a? Hash
                  rtype = rdef.delete(:type)
                  ropts = rdef
                end

                send(rtype, rname, ropts)
              end

              mdef[:fields].each do |fname, fsize|
                field(fname, fsize)
              end
            end
          end
        end
      end
    end

    module Parsing
      extend ActiveSupport::Concern

      def with_file(file, &block)
        @stack = []
        File.open(file, "r:#{encoding}:UTF-8") do |fd|
          block.call fd
        end
      end

      def get_next_document(fd)
        while line = fd.gets
          line.chomp!
          model = line_to_instance(line)
          to_be_generated = stack_instance(model)
          return to_be_generated if to_be_generated
        end

        remaining_id = some_generator_after(-1)
        remaining = remaining_id && @stack[remaining_id]
        @stack = []
        remaining
      end

      def where_is_father?(instance)
        (@stack.size - 1).downto(0) do |index|
          return index if @stack[index].may_have?(instance)
        end
        return nil
      end

      def release_existing_generator_and_replace_by(instance, gen_index)
        unstack_all_after(gen_index)
        previous_generator = @stack[gen_index]
        @stack[gen_index] = instance
        return previous_generator
      end

      def tree_shift_for_child(instance)
        father_index = where_is_father?(instance)

        if father_index
          father = @stack[father_index]
          father.embrace_child(instance)

          some_generator_after(father_index).tap do |generator_index|
            generator = generator_index && @stack[generator_index]
            unstack_all_after(father_index)
            return generator
          end
        end
        nil
      end

      def stack_instance(instance)
        if is_generator?(instance) && (gen_index = some_generator_after(-1))
          return release_existing_generator_and_replace_by(instance, gen_index)
        else
          some_generator = tree_shift_for_child(instance)
        end

        @stack << instance

        return some_generator
      end

      def some_generator_after(index)
        (index + 1).upto(@stack.size - 1).each do |i|
          return i if is_generator?(@stack[i])
        end
        nil
      end

      def unstack_all_after(idx)
        @stack.slice!(idx + 1, @stack.size)
      end

      def line_to_instance(line)
        ModelDefinition::Instance.new(identify_line(line), line, _elf = nil)
      end

      def is_generator?(instance)
        instance.type == generator_type
      end

      def identify_line(line)
        matching = models.values.select { |m| m.match?(line) }
        case matching.size
        when 0
          fail ArgumentError.new(["Unknown line type", line])
        when 1
          matching.first
        when 2
          fail ArgumentError.new(["Ambiguous line type", matching.map(&:type),   line])
        end
      end

      def parse(file)
        documents = []
        with_file(file) do |fd|
          while document = get_next_document(fd)
            if block_given?
              yield document
            else
              documents << document
            end
          end
        end
        documents unless block_given?
      end
    end
  end

  module PositionalParser
    module ModelDefinition
      class Instance
        attr_accessor :parents
        attr_reader :type, :children, :line
        def initialize(model, line, template)
          @model = model
          @line = line
          @template = template
          @children = {}
          @parents = {}
          @_attribute_values = {}
        end

        def type
          @model.type
        end

        def may_have?(other_instance)
          @model.relation_name_for(other_instance.type)
        end

        def to_s
          "<INSTANCE #{type} '#{@line.to_s[0..30]}'... >"
        end

        def embrace_child(other)
          relation = @model.relation_name_for(other.type)
          return unless relation
          children[relation] ||= []
          children[relation] << other

          other.parents[self.type] = self
        end

        def to_hash(breadcrumbs = [])
          return nil if breadcrumbs.include?(self)
          breadcrumbs << self

          @_hash ||= CaseInsensitiveHash.new.tap do |me|
            fields.each do |name, field|
              me[name] = read_attribute(field)
            end

            add_associations(me, breadcrumbs)
          end
        end

        def add_associations(me, breadcrumbs)
          @model.associations.each do |association_model_sym, config|
            association_type, options = *config
            my_association = association_model_sym
            inverse_association = (options[:inverse_of] || my_association).to_sym

            case association_type
            when 'has_one'
              me[my_association.to_s] = children[inverse_association]&.first&.to_hash(breadcrumbs)
            when 'has_many'
              me[my_association.to_s] = (children[my_association] ||= {}).map { |i| i.to_hash(breadcrumbs) }
            when 'belongs_to'
              me[my_association.to_s] = parents[my_association]&.to_hash(breadcrumbs)
            else
              fail "unknown association type #{association_type}"
            end
          end
        end

        def read_attribute(field_or_name)
          field = field_or_name.is_a?(String) ? fields[field_or_name] : field_or_name
          raise "Field not found '#{field_or_name}'" if field.nil?
          @_attribute_values[field.name] ||= begin
            fields[field.name].value_on(self)
          end
        end

        def fields
          @model.fields
        end
      end
    end
  end

  module PositionalParser
    module ModelDefinition
      class Field
        attr_reader :name
        def initialize(name, start, length, formatter_id)
          @name = name
          @start = start
          @length = length
          @formatter_id = formatter_id
        end

        def value_on(instance)
          format(instance.line[@start, @length], instance)
        end

        def format(value, instance)
          formatter.call(value, instance)
        end

        def formatter
          if @formatter_id
            Proc.new { |value, instance| value.to_s.strip }
          else
            Proc.new { |value, instance| value.to_s.strip }
          end
        end
      end
    end
  end

  module PositionalParser
    module ModelDefinition
      class Model
        attr_reader :type, :fields, :associations
        def initialize(type, matcher)
          @type = type
          @matcher = matcher
          @associations ||= {}
          @start_accumulator = 0
          @fields = {}
        end

        def match?(line)
          @matcher.match(line)
        end

        %w{has_one has_many belongs_to}.each do |association_type|
          define_method association_type do |model_sym, options = {}|
            options[:inverse_of] = options[:inverse_of].to_sym if options[:inverse_of]
            @associations[model_sym] = [association_type, options]
          end
        end

        def relation_name_for(other_model_sym)
          @associations.each do |k, conf|
            return k if (k == other_model_sym) || (conf.last && conf.last[:inverse_of] == other_model_sym)
          end
          nil
        end

        def field(name, length, formatter = :strip)
          @existing_fields ||= []
          raise "field already defined '#{name}' for #{@type}" if @existing_fields.include?(name)

          @existing_fields << name
          @fields[name] = Field.new(name, @start_accumulator, length, formatter)
          @start_accumulator += length
        end
      end
    end
  end

  module PositionalParser
    module ModelDefinition
      extend ActiveSupport::Concern

      def encoding
        self.class.encoding ||= 'utf-8'
      end

      class_methods do
        def encoding(encoding)
          cattr_accessor :encoding
          self.encoding = encoding
        end

        def model(type, matcher, &block)
          type = type.to_sym
          cattr_accessor :models
          self.models ||= {}
          self.models[type] = generate_model_type(type, matcher, &block)
        end

        def generate(model_type)
          cattr_accessor :generator_type
          self.generator_type = model_type.to_sym
          # TODO validate is a model
        end

        def generate_model_type(type, matcher, &block)
          Model.new(type, matcher).tap do |me|
            me.instance_eval &block
          end
        end
      end
    end
  end
end
