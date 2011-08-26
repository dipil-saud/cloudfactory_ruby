Feature: Whoami credentials
  In order to talk with cloud factory
  As a CLI user
  I want to know my email
  
  @announce, @moderate_slow_process
  Scenario: Whoami
    When I run `cf whoami?`
    # Then the output should match:
    #   """
    #   john@doe.com and secret
    #   """
