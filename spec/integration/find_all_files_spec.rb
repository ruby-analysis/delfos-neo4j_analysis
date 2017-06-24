require "spec_helper"
require "delfos/neo4j_analysis"

RSpec.describe do
  it "finds all call_sites which call a specific method" do
    result = Delfos::Neo4jAnalysis.call_sites("Bundler::RemoteSpecification#dependencies")

    expect(result).to eq [
      [
        {
          "file"          => "lib/bundler.rb",
         "line_number" => 193
      },

         {"file"        => "lib/bundler.rb",
          "name"        => "install_path",
          "line_number" => 192,
          "type"        => "ClassMethod"}
    ]
    ]
  end

  it "finds all call_sites which eventually call a specific method" do
    Delfos::Neo4jAnalysis.call_stack_ancestors("Product#name")
  end
end
