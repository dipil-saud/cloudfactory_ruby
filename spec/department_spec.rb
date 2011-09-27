require 'spec_helper'

describe CF::Department do
  context "return category" do
    it "should get all the departments" do
      departments = CF::Department.all
      departments_name = departments.map {|d| d['name']}.join(",")
      departments_name.should include("Digitization")
      departments_name.should include("Data Processing")
      departments_name.should include("Survey")
    end
  end
end
