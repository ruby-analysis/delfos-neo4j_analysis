require "values"
require "delfos"
require "delfos/neo4j"

require "delfos/neo4j_analysis/version"
require "delfos/neo4j_analysis/call_site_fetcher"
require "delfos/neo4j_analysis/class_listing"
require "delfos/neo4j_analysis/all_class_listing"
require "delfos/neo4j_analysis/method_listing"
require "delfos/neo4j_analysis/execution_chain"

Delfos.configure

module Delfos
  module Neo4jAnalysis
    def self.call_sites(short_hand)
      CallSiteFetcher.new(short_hand).fetch
    end

    def self.list_classes
      ClassListing.perform
    end

    def self.list_all_classes
      AllClassListing.perform
    end

    def self.list_methods(klass, path_prefix)
      MethodListing.perform(klass, path_prefix)
    end

    def self.execution_chain(uuid: nil, path_prefix: "")
      ExecutionChain.perform(uuid, path_prefix)
    end
  end
end
