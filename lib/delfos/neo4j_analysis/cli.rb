#!/usr/bin/env ruby

require "highline"
require "byebug"
require "delfos"
require "delfos/neo4j_analysis"

module Delfos
  module Neo4jAnalysis
    class Cli
      class << self
        attr_accessor :path_prefix

        def start(port, path_prefix)
          self.path_prefix = path_prefix

          Delfos.configure do |c|
            c.neo4j.port = port
          end

          new.start
        end
      end

      def cli
        @cli ||= HighLine.new
      end

      def start
        cli.choose do |menu|
          menu.prompt = "Choose an action"
          menu.default = "List application classes"
          setup_choices!(menu)
          menu.choice("Exit") { exit 0 }
        end until false
      end

      def setup_choices!(menu)
        menu.choice("Find call sites") {
          short_hand = cli.ask("Enter a method to search for: e.g. Product#name") do |q|
            q.default = "Bundler.ui"
          end

          cli.say "Searching for #{short_hand}"
          call_sites = Neo4jAnalysis.call_sites(short_hand)
          formatted = call_sites.map{|c| "#{Cli.path_prefix}#{c}"}.join("\n")
          cli.say formatted
        }
        menu.choice("Find methods which eventually call a method") do
          short_hand = cli.ask("Enter a method to search for: e.g. Product#name")

          cli.say Neo4jAnalysis.methods_which_eventually_call_a_method(short_hand)
        end
        menu.choice("List application classes" ) { cli.say Neo4jAnalysis.list_classes }

        menu.choice("List all classes") do
          cli.say Neo4jAnalysis.list_all_classes
        end

        menu.choice("List methods") do
          klass = cli.ask("Enter a Class")
          cli.say Neo4jAnalysis.list_methods(klass)
        end

        menu.choice("Random execution chain") do
          chain = Neo4jAnalysis.execution_chain
          cli.say chain.source
          finish = false

          until finish
            command = cli.ask("(a)ll steps,  (s)tep, (u), (q)uit? "){ |c| %w(a s u q).include?(c) }

            case command
            when "a"
              cli.say chain.all
            when "s"
              cli.say chain.next
            when "u"
              cli.say chain.previous
            when "q"
              finish = true
            end
          end
        end
      end
    end
  end
end
