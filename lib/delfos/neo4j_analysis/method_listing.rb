
module Delfos
  module Neo4jAnalysis
    class MethodListing
      def self.perform(klass_name, path_prefix)
        new.perform(klass_name, path_prefix).join("\n")
      end

      def perform(klass_name, path_prefix)
        results = results(klass_name)

        max_length = results.map(&:first).map(&:length).sort.last

        results.map do |name, file, line_number|
          name = name.ljust(max_length, " ")

          "#{name}  #{path_prefix}#{file}:#{line_number}"
        end.sort.uniq
      end

      def results(klass_name)
        Neo4j.execute_sync <<-QUERY, klass_name: klass_name
          MATCH
            (Class)
              -[:OWNS]     -> (Method)
              -[:CONTAINS] -> (CallSite)

              -[:CALLS]    -> (m:Method)
              -[:CONTAINS] -> (cs:CallSite),

            (m)
              <-[:OWNS]- (Class{name: {klass_name}})

          RETURN m.name, m.file, m.line_number
          ORDER BY m.name
        QUERY
      end
    end
  end
end

