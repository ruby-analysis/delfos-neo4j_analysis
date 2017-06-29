module Delfos
  module Neo4jAnalysis
    class CallStack
      def self.perform(uuid)
        new(uuid)
      end

      attr_reader :uuid, :step

      def initialize(uuid)
        @uuid = uuid
        @step = 1
      end

      def all
        all = entries.map(&:summary)
        first_width  = all.map(&:first ).map(&:length).max
        second_width = all.map(&:second).map(&:length).max

        all.map do |location, container, called|
          first = location.ljust(first_width, " ")
          second = container.ljust(second_width)
          "#{first} #{second} -> #{called}"
        end.join("\n")
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
        @entries ||= results.map do |file, line_number, summary, called_method_name, called_method_summary|
          CallSite.new(file, line_number, summary, called_method_name, called_method_summary)
        end
      end

      class CallSite
        attr_reader :file, :line_number, :source, :offset, :container_method_summary, :called_method_name, :called_method_summary

        def initialize(file, line_number, container_method_summary, called_method_name, called_method_summary)
          @offset                   = 5
          @file                     = file
          @line_number              = line_number
          @container_method_summary = container_method_summary
          @called_method_name       = called_method_name
          @called_method_summary    = called_method_summary

          @source                   = determine_source
        end

        def summary
          [location, container_method_summary, called_method_summary]
        end

        def location
          "#{Cli.path_prefix}#{file}:#{line_number}"
        end

        private

        STACK_SEPARATOR = "-" * 80, "\n"

        def call_summary
          [container_method_summary, called_method_summary].join " -> "
        end

        def determine_source
          if filename && line_number
            [STACK_SEPARATOR, location, "\n",
             call_summary,
             pretty_source,
             "\n", ].join("")
          else
            "No source found for `#{location}'"
          end
        end

        def pretty_source
          [before, line, method_indicator,after].join("")
        end


        def method_indicator
          to_find = called_method_name == "initialize" ? "new" : called_method_name
          method_location = raw_line.index(to_find) || 0

          if method_location
            (" " * method_location) + "^\n"
          else
            "^" * 80 + "\n"
          end
        end

        def separator
          class_method ? "." : "#"
        end

        def lines
          @lines ||= `rougify #{filename}`.split("\n").map{|l| "#{l}\n"}
        end

        def raw_line
          return unless filename

          raw_lines[line_number-1]
        end

        def raw_lines
          @raw_lines ||= with_cache(filename) do
            File.readlines(filename)
          end
        end

        def self.file_cache
          @file_cache ||= {}
        end

        def with_cache(key)
          self.class.file_cache[key] ||= yield
        end

        def filename
          return @filename if defined? @filename

          @filename = "#{Cli.path_prefix}#{file}"

          return @filename if File.exist?(@filename)

          if File.exist?(file)
            @filename = file
            return @filename
          end
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
        end

        def after_range
          finish = [line_number + offset, last_line_index].min
          line_number .. finish
        end

        def last_line_index
          lines.length - 1
        end
      end

      private

      def results
        Neo4j.execute_sync <<-QUERY, params
          MATCH (cs:CallStack{uuid: {uuid}})-[step:STEP]->(call_site)
          <-[:CONTAINS]-(container:Method)<-[:OWNS]-(container_class:Class),

          (call_site)-[:CALLS]->(called:Method)<-[:OWNS]-(called_class:Class)

          RETURN

          call_site.file,

          call_site.line_number,

          container_class.name +
            CASE
            WHEN container.type = "InstanceMethod" THEN "#"
            WHEN container.type = "ClassMethod" THEN "."
            END +
          container.name ,

          called.name,

          called_class.name +
            CASE
            WHEN called.type = "InstanceMethod" THEN "#"
            WHEN called.type = "ClassMethod" THEN "."
            END +
          called.name

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
          WHERE steps > 10 AND steps < 100
          RETURN uuid
          LIMIT 1
        QUERY
      end
    end
  end
end

