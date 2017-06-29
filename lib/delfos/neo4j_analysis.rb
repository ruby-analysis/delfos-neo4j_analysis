require "values"
require "active_support/all"

require "delfos"
require "delfos/neo4j"

require "delfos/neo4j_analysis/version"
require "delfos/neo4j_analysis/call_site_fetcher"
require "delfos/neo4j_analysis/methods_which_eventually_call_a_method"
require "delfos/neo4j_analysis/class_listing"
require "delfos/neo4j_analysis/all_class_listing"
require "delfos/neo4j_analysis/method_listing"
require "delfos/neo4j_analysis/call_stack"

Delfos.configure

module Delfos
  module Neo4jAnalysis
    def self.call_sites(short_hand)
      CallSiteFetcher.new(short_hand).perform
    end

    def self.methods_which_eventually_call_a_method(short_hand)
      MethodsWhichEventuallyCallAMethod.perform(short_hand)
    end

    def self.list_classes
      ClassListing.perform
    end

    def self.list_all_classes
      AllClassListing.perform
    end

    def self.list_methods(klass)
      MethodListing.perform(klass)
    end

    def self.execution_chain(uuid: nil)
      CallStack.perform(uuid)
    end
  end
end
