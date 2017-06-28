module Delfos
  module Neo4jAnalysis
    class ClassListing
      def self.perform
        new.perform.join("\n")
      end

      def perform
        Neo4j.execute_sync <<-QUERY
          MATCH
            (Class)
              -[:OWNS]     -> (Method)
              -[:CONTAINS] -> (CallSite)
              -[:CALLS]    -> (m:Method)
              -[:CONTAINS] -> (cs:CallSite),

            (m)<-[:OWNS]-(c:Class)

          RETURN distinct(c.name) 
          ORDER BY c.name
        QUERY
      end
    end
  end
end


