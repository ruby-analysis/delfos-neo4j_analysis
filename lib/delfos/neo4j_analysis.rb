require "values"
require "delfos/neo4j"

require "delfos/neo4j_analysis/version"
require "delfos/neo4j_analysis/method_definition_argument_parser"


module Delfos
  module Neo4jAnalysis
    CallSite = Value.new("file", "line_number")
    Method   = Value.new("file", "line_number", "klass", "name", "type")

    def self.call_sites(short_hand)
      CallSiteFetcher.new(short_hand).fetch
    end

    class CallSiteFetcher
      def initialize(short_hand)
        @short_hand = short_hand
      end

      def fetch
        results.map{|r| parse(*r)}
      end

      private

      def parse(call_site_attrs, method_attrs, klass_attrs)
        call_site        = CallSite.with(call_site_attrs)
        container_method = method_from(method_attrs, klass_attrs)

        [container_method, call_site]
      end


      def method_from(method_attrs, klass_attrs)
        method_attrs = method_attrs.merge("klass" => klass_attrs["name"])
        Method.with(method_attrs)
      end

      def results
        Neo4j.execute_sync <<-QUERY, params
          MATCH (:Class{name: {klass_name}})
            -[:OWNS]->
          (:Method{name:{method_name}, type:{method_type}})

          <-[:CALLS]-(call_site:CallSite)
          <-[:CONTAINS]-(container_method:Method)
          <-[:OWNS]-(container_klass:Class)


          RETURN call_site, container_method, container_klass
        QUERY
      end

      def params
        MethodDefinitionArgumentParser.parse @short_hand
      end
    end

  end
end
