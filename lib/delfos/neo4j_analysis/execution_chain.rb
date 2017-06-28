require_relative "method_definition_argument_parser"

module Delfos
  module Neo4jAnalysis
    class CallSiteFetcher
      def initialize(short_hand)
        @short_hand = short_hand
      end

      def perform
        results.map{|r| r.join(":") }.sort.uniq
      end

      private

      def results
        Neo4j.execute_sync <<-QUERY, params
          MATCH (:Class{name: {klass_name}})
            -[:OWNS]->
          (:Method{name:{method_name}, type:{method_type}})

          <-[:CALLS]-(call_site:CallSite)
          <-[:CONTAINS]-(container_method:Method)
          <-[:OWNS]-(container_klass:Class),

          (container_method)<-[:CALLS]-(outer_call_site:CallSite)

          RETURN call_site.file, call_site.line_number
        QUERY
      end

      def params
        MethodDefinitionArgumentParser.parse @short_hand
      end
    end
  end
end

