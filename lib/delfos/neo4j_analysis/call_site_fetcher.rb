require_relative "method_definition_argument_parser"

module Delfos
  module Neo4jAnalysis
    class ExecutionChain
      def self.perform(uuid, prefix)
        new(uuid, prefix)
      end

      attr_reader :uuid, :prefix, :step

      def initialize(uuid, prefix)
        @uuid, @prefix = uuid, prefix
        @step = 1
      end

      def source
        entries[step - 1].source
      end

      def next
        self.step = step + 1
        source
      end

      def step=(i)
        @step = i
        @step = [entries.length, @step].min
        @step = [1, @step].max
      end

      def previous
        self.step = step - 1
        source
      end

      def entries
        @entries ||= results.sort_by(&:first).map do |_, file, line_number|
          CallStackEntry.new(file, line_number, prefix)
        end
      end

      class CallStackEntry
        attr_reader :file, :line_number, :prefix, :source, :offset

        def initialize(file, line_number, prefix)
          @offset = 5
          @file        = file
          @line_number = line_number
          @prefix      = prefix
          @source      = determine_source
        end

        private

        def determine_source
          if filename && line_number
            ["-" * 80, "\n",prefix, location, "\n", before, line, "^"*80,"\n", after].join("")
          else
            "No source found for `#{location}'"
          end
        end

        def lines
          @lines ||= `rougify #{filename}`.split("\n").map{|l| "#{l}\n"}
        end

        def location
          [file, line_number].join(":")
        end

        def filename
          filename = "#{prefix}#{file}"

          return filename if File.exist?(filename)
          return file if File.exist?(file)
        end

        def before
          Array(lines[before_range]).join("")
        end

        def line
          lines[line_number-1]
        end

        def after
          Array(lines[after_range]).join("")
        end

        def before_range
          start = [line_number - offset, 0].max
          start .. line_number-2
        rescue
          byebug
        end

        def after_range
          finish = [line_number + offset, last_line_index].min
          line_number + 1 .. finish
        rescue
          byebug
        end

        def last_line_index
          lines.length - 1
        end
      end

      private

      def results
        Neo4j.execute_sync <<-QUERY, params
          MATCH (cs:CallStack{uuid: {uuid}})-[step:STEP]->(call_site)

          RETURN step.number, call_site.file, call_site.line_number
          ORDER BY step.number
        QUERY
      end

      def params
        {uuid: uuid}
      end

      def uuid
        @uuid ||= Neo4j.execute_sync(<<-QUERY).flatten.first
          MATCH (cs:CallStack)-[step:STEP]->(call_site)
          WITH cs.uuid as uuid, count(step) as steps
          WHERE steps = 10
          RETURN uuid
          ORDER BY rand()
          LIMIT 1
        QUERY
      end
    end
  end
end

