module Delfos
  module Neo4jAnalysis
    class MethodDefinitionArgumentParser
      def self.parse(short_hand)
        new(short_hand).parse
      end

      attr_reader :short_hand

      def initialize(short_hand)
        @short_hand = short_hand
      end

      def parse
        {
          klass_name: klass_name,
          method_type: method_type,
          method_name: method_name
        }
      end

      private

      def klass_name
        klass_name = short_hand.split(separator).first
        raise_error "Class name", klass_name unless klass_name[/^[A-Z]/]

        if klass_name[/\w:\w/] || klass_name[" "] || klass_name[/:$/]
          raise_error "Class name", klass_name
        end

        klass_name
      end

      def raise_error(type, text)
        raise ArgumentError.new("Invalid #{type} '#{text}' in '#{short_hand}'")
      end

      def method_name
        short_hand.split(separator).last
      end

      def method_type
        separator == "." ? "ClassMethod" : "InstanceMethod"
      end

      def separator
        check_separator!

        class_method_count == 1 ? "." : "#"
      end

      def check_separator!
        raise_error("Separator", short_hand) unless separator_count == 1
      end

      def separator_count
        class_method_count + instance_method_count
      end

      def class_method_count
        short_hand.count(".")
      end

      def instance_method_count
        short_hand.count "#"
      end
    end
  end
end

