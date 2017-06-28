module Delfos
  module Neo4jAnalysis
    class AllClassListing
      def self.perform
        new.perform.sort.join("\n")
      end

      def perform
        Neo4j.execute_sync <<-QUERY
          MATCH (c:Class)
          RETURN distinct(c.name)
          ORDER BY c.name
        QUERY
      end
    end
  end
end

