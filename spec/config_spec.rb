require 'spec_helper'

describe CF do
  context "configuration" do
    it "be able to configure the api key" do
      API_CONFIG = YAML.load_file(File.expand_path("../../fixtures/api_credentials.yml", __FILE__))
      CF.configure do |config|
        config.account_name = API_CONFIG['account_name']
        config.api_version = API_CONFIG['api_version']
        config.api_url = API_CONFIG['api_url']
        config.api_key = API_CONFIG['api_key']
      end
      
      CF.account_name.should eql(API_CONFIG['account_name'])
      CF.api_key.should eql(API_CONFIG['api_key'])
      CF.api_url.should eql(API_CONFIG['api_url'])
      CF.api_version.should eql(API_CONFIG['api_version'])
    end
  end
end