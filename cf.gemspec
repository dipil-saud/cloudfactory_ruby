# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "cf/version"

Gem::Specification.new do |s|
  s.name        = "cloudfactory"
  s.version     = CF::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["CloudFactory.com"]
  s.email       = ["info@cloudfactory.com"]
  s.homepage    = "http://cloudfactory.com"
  s.summary     = %q{A Ruby wrapper and CLI for Cloudfactory.com}
  s.description = %q{A Ruby wrapper and CLI for to interact with Cloudfactory.com REST API}

  s.rubyforge_project = "cloudfactory"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["cf"]
  s.require_paths = ["lib"]

  s.post_install_message =<<EOF
--------------------------------------------------------------------------------

  Sweet. You now have the 'cf' command installed. Test drive it with:
  > cf help

  1. Sign up for your CloudFactory account and get your API key
  http://cloudfactory.com/users/sign_up
  Get API key from welcome email or http://cloudfactory.com/account#settings

  2. Login with your credentials
  > cf login
  
  3. Generate your first assembly line...
  > cf line generate <line-title>
  
  4. Go into generated line directory
  > cd <line-title>
  
  5. Edit the generated line.yml to design your perfect assembly line
  See http://developers.cloudfactory.com/lines/yaml.html
  
  6. Create your line in CloudFactory
  > cf line create

  7. Do a test production run in the sandbox first...
  > cf production start TITLE -i=INPUT_DATA.CSV

  8. Go live! Send your production run to real workers...
  > cf production start TITLE -i=INPUT_DATA.CSV --live
  
 ------------------------------------------------------------------------------
 
  Follow @thecloudfactory on Twitter for announcements, updates, and news.
  https://twitter.com/thecloudfactory

  Add your project or organization to the apps wiki!
  https://github.com/sprout/cloudfactory_ruby/wiki/Apps
  
--------------------------------------------------------------------------------
EOF

  s.add_dependency  "i18n"
  s.add_dependency  "activesupport", '~> 3.0'
  s.add_dependency  "hashie", "~> 1.0"
  s.add_dependency  "rest-client"
  s.add_dependency  "json"
  s.add_dependency  "thor", "~> 0.14"
  s.add_dependency  "highline"
  s.add_dependency  "httparty", "~> 0.7"
  s.add_dependency  "terminal-table", "~> 1.4"
  s.add_dependency  "millisami-csv-hash"
  s.add_dependency  "awesome_print"
  
  s.add_development_dependency 'ruby-debug19'
  s.add_development_dependency "aruba"
  s.add_development_dependency "rails", "~> 3.0.3"
  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "generator_spec", "~> 0.8.3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "rdoc", "~> 3.5.3"
  s.add_development_dependency "vcr"
  s.add_development_dependency "rake"
  s.add_development_dependency "webmock"
  s.add_development_dependency "timecop"
end
