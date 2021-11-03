require_relative "method_definition_argument_parser"

module Delfos
  module Neo4jAnalysis
    class MethodsWhichEventuallyCallAMethod
      def self.perform(short_hand)
        new(short_hand).perform
      end

      def initialize(short_hand)
        @short_hand = short_hand
      end

      def perform
        results.map{|l, s| "#{l} #{s}"}.sort.uniq.join("\n")
      end

      private

      def results
        Neo4j.execute_sync <<-QUERY, params
          MATCH (:Class{name: $klass_name})
            -[:OWNS]->
          (:Method{name:$method_name, type:$method_type})
          <-[:CALLS]-(call_site:CallSite)<-[call_step:STEP]-(call_stack:CallStack),

          (call_stack)-[previous_step:STEP]->(previous_call_site:CallSite)
          <-[:CONTAINS]-(method:Method)
          <-[:OWNS]-(klass:Class)


          WITH call_site, call_step, previous_step, method, klass
          WHERE previous_step.number < call_step.number

          RETURN call_site.file + ":" + call_site.line_number,

          klass.name +
            CASE
            WHEN method.type = "InstanceMethod" THEN "#"
            WHEN method.type = "ClassMethod" THEN "."
            END +
          method.name

        QUERY
      end

      def params
        MethodDefinitionArgumentParser.parse @short_hand
      end
    end
  end
end

