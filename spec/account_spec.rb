require 'spec_helper'

describe CF::Account do
  it "should get the account info" do
    WebMock.allow_net_connect!
    account_info = CF::Account.info
    account_info['name'].should eql("4r9t")
  end
end