require "delfos/neo4j"

require "delfos/neo4j_analysis/version"
require "delfos/neo4j_analysis/method_definition_argument_parser"

module Delfos
  module Neo4jAnalysis
    CodeLocation = Struct.new(:file, :line_number)

    def self.call_sites(short_hand)
      params = MethodDefinitionArgumentParser.parse short_hand

      results = Neo4j.execute_sync <<-QUERY, params
        MATCH (:Class{name: {klass_name}})
          -[:OWNS]->
        (:Method{name:{method_name}, type:{method_type}})

        <-[:CALLS]-(call_site:CallSite)
        <-[:CONTAINS]-(container_method:Method)
        <-[:OWNS]-(container_klass:Class)



        RETURN call_site, container_method, container_klass
      QUERY

      factory = Delfos::MethodTrace::CodeLocation

      results.map do |call_site_attrs, container_method_attrs, container_klass_attrs|
        container_method_attrs


        [container_method.summary, call_site.summary]
      end
    end
  end
end
