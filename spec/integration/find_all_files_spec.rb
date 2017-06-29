require "spec_helper"
require "delfos/neo4j_analysis"

RSpec.describe do
  def new_method(attrs)
    Delfos::Neo4jAnalysis::Method.with(attrs.stringify_keys)
  end
  def new_call_site(attrs)
    Delfos::Neo4jAnalysis::CallSite.with(attrs.stringify_keys)
  end

  before do
    Delfos.configure
  end

  let(:expected) do
    [
      [
        new_method(
          file: "lib/bundler/remote_specification.rb",
          line_number: 53,
          klass: "Bundler::RemoteSpecification",
          name: "__swap__",
          type: "InstanceMethod"
        ),

        new_call_site(file: "lib/bundler/remote_specification.rb", line_number: 54)
      ],

      [
        new_method(
          file: "lib/bundler/spec_set.rb",
          line_number: 180,
          klass: "Bundler::SpecSet",
          name: "tsort_each_child",
          type: "InstanceMethod"
        ),

        new_call_site(file: "lib/bundler/spec_set.rb", line_number: 181)
      ],

      [
        new_method(
          file: "lib/bundler/resolver.rb",
          line_number: 98,
          klass: "Bundler::Resolver::SpecGroup",
          name: "to_specs",
          type: "InstanceMethod"
        ),

        new_call_site( file: "lib/bundler/resolver.rb", line_number: 102)
      ],

      [
        new_method(
          file: "lib/bundler/resolver.rb",
          line_number: 148,
          klass: "Bundler::Resolver::SpecGroup",
          name: "__dependencies",
          type: "InstanceMethod"
        ),

        new_call_site( file: "lib/bundler/resolver.rb", line_number: 152)
      ]
    ]
  end

  it "finds all call_sites which call a specific method" do
    result = Delfos::Neo4jAnalysis.call_sites("Bundler::RemoteSpecification#dependencies")

    expected.each_with_index do |(expected_container_method, expected_call_site), index|
      expect(result[index].first).to eq expected_container_method
      expect(result[index].last). to eq expected_call_site
    end
  end

  it "finds all call_sites which eventually call a specific method" do
    Delfos::Neo4jAnalysis.call_stack_ancestors("Product#name")
  end
end
