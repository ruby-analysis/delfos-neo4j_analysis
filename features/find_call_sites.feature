Feature: Finding call sites
  Scenario: Running "delfos_analysis"
    When I run "delfos_analysis"
    Then the output should contain:
      """
      Delfos Analysis
      ---------------
      Enter a method to search for: e.g. Product#name
      >
      """


