require 'spec_helper'

describe CF::InputFormat do
  context "create an input header" do
    it "in plain ruby way within line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/plain-ruby/create-within-line", :record => :new_episodes do
        line = CF::Line.new("Digitize","Digitization")
        input_format = CF::InputFormat.new({:name => "Company", :required => true, :valid_type => "general"})
        line.input_formats input_format
        line.input_formats.first.name.should eql("Company")
        line.input_formats.first.valid_type.should eql("general")
      end
    end

    it "in plain ruby way within station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/plain-ruby/create", :record => :new_episodes do
        attrs = {:name => "image_url",
          :required => true, 
          :valid_type => "url"
        }

        line = CF::Line.new("Digitize-121","Digitization")
        input_format = CF::InputFormat.new(attrs)
        line.input_formats input_format
        input_format1 = CF::InputFormat.new({:name => "image", :required => true, :valid_type => "url"})
        line.input_formats input_format1
        station = CF::Station.new({:type => "work"})
        line.stations station

        line.title.should eq("Digitize-121")
        line.input_formats.first.name.should eq("image_url")
        line.input_formats.first.required.should eq(true)
        line.input_formats.first.valid_type.should eq("url")
        line.input_formats.last.name.should eq("image")
        line.input_formats.last.required.should eq(true)
        line.input_formats.last.valid_type.should eq("url")
      end
    end

    it "in block DSL way within line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/block/create-input-headers-of-line", :record => :new_episodes do 
        line = CF::Line.create("Digitize-2","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
        end
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].name.should eq("image")
      end
    end
    
    it "in block DSL way within line without valid_type" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/block/create-input-headers-of-line-1", :record => :new_episodes do 
        line = CF::Line.create("input_format_without_valid_type","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :name => "image", :required => true})
        end
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].name.should eq("image")
      end
    end

    it "in block DSL way within station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/block/create-input-headers-of-station", :record => :new_episodes do 
        line = CF::Line.create("Digitize-3","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
          CF::Station.new({:line => l, :type => "work"})
        end
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].name.should eq("image")
      end
    end
    
    it "should only display the attributes which are mentioned in to_s method" do
      VCR.use_cassette "input_formats/block/display-to_s", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Display_input_format", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
          end
        end
        line.input_formats.first.to_s.should eql("{:id => #{line.input_formats.first.id}, :name => image_url, :required => true, :valid_type => url, :errors => }")
      end
    end
  end

  context "return all the input headers" do
    it "should return all the input headers of a line " do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/block/input-headers-of-line", :record => :new_episodes do 
        line = CF::Line.create("Digitize-111","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
          CF::Station.new({:line => l, :type => "work"})
        end
        input_formats_of_line = CF::InputFormat.all(line)
        # => getting input_formats response need to be modified 
        input_formats_of_line.map(&:name).should include("image_url")
        input_formats_of_line.map(&:name).should include("image")
        input_formats_of_line.map(&:valid_type).should include("url")
      end
    end
  end
  
  context "create an input_format" do
    it "in Block DSL way without name to set the error attribute" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/block/create-invalid-input-formats", :record => :new_episodes do 
        line = CF::Line.create("Digitize-2","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :required => true, :valid_type => "url"})
        end
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].errors.should eql(["Name can't be blank"])
      end
    end
    
    it "in plain Ruby way with invalid data to set the error attribute" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "input_formats/plain-ruby/create-invalid-input-formats", :record => :new_episodes do 
        line = CF::Line.new("Digitize-3","Digitization")
        input_format_1 = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.input_formats input_format_1
        input_format_2 = CF::InputFormat.new({:required => true, :valid_type => "url"})
        line.input_formats input_format_2
        
        line.input_formats[0].name.should eq("image_url")
        line.input_formats[1].errors.should eql(["Name can't be blank"])
      end
    end
  end
end