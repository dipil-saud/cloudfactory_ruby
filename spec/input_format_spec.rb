require 'spec_helper'

describe CF::InputFormat do
  context "create an input header" do
    it "in plain ruby way within line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title,"Digitization")
      input_format = CF::InputFormat.new({:name => "Company", :required => true})
      line.input_formats input_format
      line.input_formats.first.name.should eql("Company")
    end

    it "in plain ruby way within station" do
      WebMock.allow_net_connect!
      attrs = {:name => "image_url",
        :required => true, 
        :valid_type => "url"
      }
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title,"Digitization")
      input_format = CF::InputFormat.new(attrs)
      line.input_formats input_format
      input_format1 = CF::InputFormat.new({:name => "image", :required => true, :valid_type => "url"})
      line.input_formats input_format1
      station = CF::Station.new({:type => "work"})
      line.stations station

      line.title.should eq(title)
      line.input_formats.first.name.should eq("image_url")
      line.input_formats.first.required.should eq(true)
      line.input_formats.first.valid_type.should eq("url")
      line.input_formats.last.name.should eq("image")
      line.input_formats.last.required.should eq(true)
      line.input_formats.last.valid_type.should eq("url")
    end

    it "in block DSL way within line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
      end
      line.input_formats[0].name.should eq("image_url")
      line.input_formats[1].name.should eq("image")
    end

    it "in block DSL way within line without valid_type" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :name => "image", :required => true})
      end
      line.input_formats[0].name.should eq("image_url")
      line.input_formats[1].name.should eq("image")
    end

    it "in block DSL way within station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
        CF::Station.new({:line => l, :type => "work"})
      end
      line.input_formats[0].name.should eq("image_url")
      line.input_formats[1].name.should eq("image")
    end

    it "should only display the attributes which are mentioned in to_s method" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
        end
      end
      line.input_formats.first.to_s.should eql("{:id => #{line.input_formats.first.id}, :name => image_url, :required => true, :valid_type => url, :errors => }")
    end
  end

  context "return all the input headers" do
    it "should return all the input headers of a line " do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
        CF::Station.new({:line => l, :type => "work"})
      end
      input_formats_of_line = CF::InputFormat.all(line)
      # => getting input_formats response need to be modified
      names = input_formats_of_line.map {|i| i['name']}.join(",")
      names.should include("image_url")
      names.should include("image")
      input_formats_of_line.map {|i| i['valid_type']}.join(",").should include("url")
    end
  end

  context "create an input_format" do
    it "in Block DSL way without name to set the error attribute" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :required => true, :valid_type => "url"})
      end
      line.input_formats[0].name.should eq("image_url")
      line.input_formats[1].errors.should eql(["Name can't be blank"])
    end

    it "in plain Ruby way with invalid data to set the error attribute" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title,"Digitization")
      input_format_1 = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
      line.input_formats input_format_1
      input_format_2 = CF::InputFormat.new({:required => true, :valid_type => "url"})
      line.input_formats input_format_2

      line.input_formats[0].name.should eq("image_url")
      line.input_formats[1].errors.should eql(["Name can't be blank"])
    end
  end
end