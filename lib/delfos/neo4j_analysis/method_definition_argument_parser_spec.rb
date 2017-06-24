
require_relative "method_definition_argument_parser"

module Delfos
  module Neo4jAnalysis
    RSpec.describe MethodDefinitionArgumentParser do
      it do
        result = described_class.parse("Dog#now")
        expect(result).to eq(
          {
            klass_name: "Dog",
            method_type: "InstanceMethod",
            method_name: "now"
          }
        )
      end

      it do
        result = described_class.parse("Egg::Cheese#method")
        expect(result.values).to eq ["Egg::Cheese", "InstanceMethod", "method"]

        result = described_class.parse("Egg::Cheese::FurtherNesting#method")
        expect(result.values).to eq ["Egg::Cheese::FurtherNesting", "InstanceMethod", "method"]
      end

      it do
        result = described_class.parse("Egg.new")
        expect(result.values).to eq ["Egg", "ClassMethod", "new"]
      end

      it do
        aggregate_failures do
          expect{described_class.parse("Egg:Cheese#method")  }.to raise_error ArgumentError
          expect{described_class.parse("Egg :Cheese#method") }.to raise_error ArgumentError
          expect{described_class.parse("Egg..Cheese#method") }.to raise_error ArgumentError
          expect{described_class.parse("Egg..method")        }.to raise_error ArgumentError
          expect{described_class.parse("Egg#.method")        }.to raise_error ArgumentError
          expect{described_class.parse("Egg.#method")        }.to raise_error ArgumentError
          expect{described_class.parse("Egg::#method")       }.to raise_error ArgumentError
          expect{described_class.parse("Egg::method")        }.to raise_error ArgumentError
          expect{described_class.parse("Eggmethod")          }.to raise_error ArgumentError
          expect{described_class.parse("egg.new")            }.to raise_error ArgumentError
          expect{described_class.parse("egg#new")            }.to raise_error ArgumentError
        end
      end
    end
  end
end

