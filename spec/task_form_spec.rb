require 'spec_helper'

describe CF::TaskForm do
  context "create a task_form" do
    it "the plain ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      form = line.stations[0].form
      form.title.should eq("Enter text from a business card image")
      form.instruction.should eq("Describe")
      form.form_fields.first.label.should eq("First Name")
      form.form_fields.first.field_type.should eq("short_answer")
      form.form_fields.first.required.should eq(true)
    end

    it "should only display the attributes which are mentioned in to_s method" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.form.to_s.should eql("{:title => Enter text from a business card image, :instruction => Describe, :form_fields => #{line.stations.first.form.form_fields}, :errors => }")
    end

    it "with blank data" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.new({:station => station})
        end
      end
      form = line.stations[0].form
      form.errors.should eql(["Title can't be blank", "Instruction can't be blank"])
      form.instruction.should eq(nil)
      form.form_fields.should eq([])
    end

    it "without Title" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.new({:station => station, :instruction => "describe"})
        end
      end
      form = line.stations[0].form
      form.errors.should eql(["Title can't be blank"])
      form.instruction.should eq("describe")
      form.form_fields.should eq([])
    end

    it "without Instruction" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.new({:station => station, :title => "title"})
        end
      end
      form = line.stations[0].form
      form.errors.should eql(["Instruction can't be blank"])
      form.title.should eq("title")
      form.form_fields.should eq([])
    end
  end

  context "get instruction info" do
    it "should get all the instruction information of a station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      got_instruction = line.stations.first.get_form
      got_instruction['title'].should eq("Enter text from a business card image")
      got_instruction['instruction'].should eq("Describe")
    end
  end
end