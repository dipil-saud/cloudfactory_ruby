require 'spec_helper'

describe CF::FormField do
  context "create an form_field" do
    it "the plain ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")

      input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
      line.input_formats input_format

      station = CF::Station.new({:type => "work"})
      line.stations station

      worker = CF::HumanWorker.new({:number => 1, :reward => 20})
      line.stations.first.worker = worker

      form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
      line.stations.first.form = form

      form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields form_fields_1
      form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "short_answer"})
      line.stations.first.form.form_fields form_fields_2
      form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields form_fields_3
      form_fields_3 = CF::FormField.new({:label => "Gender", :field_type => "radio_button", :required => "true", :option_values => ["male","female"]})
      line.stations.first.form.form_fields form_fields_3

      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[0].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[0].required.should eq(true)
      line.stations.first.form.form_fields[0].form_field_params.should eql({:label => "First Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[1].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[1].form_field_params.should eql({:label => "Middle Name", :field_type => "short_answer"})
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
      line.stations.first.form.form_fields[2].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[2].required.should eq(true)
      line.stations.first.form.form_fields[2].form_field_params.should eql({:label => "Last Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields[3].label.should eq("Gender")
      line.stations.first.form.form_fields[3].field_type.should eq("radio_button")
      line.stations.first.form.form_fields[3].required.should eq(true)
      line.stations.first.form.form_fields[3].form_field_params.should eql({:label => "Gender", :field_type => "radio_button", :required => "true", :option_values => ["male","female"]})
    end

    it "in block DSL way" do
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
            CF::FormField.new({:form => i, :label => "Gender", :field_type => "radio_button", :required => "true", :option_values => ["male","female"]})
          end
        end
      end
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.input_formats.first.name.should eql("image_url")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[0].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[0].required.should eq(true)
      line.stations.first.form.form_fields[0].form_field_params.should eql({:label => "First Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[1].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[1].form_field_params.should eql({:label => "Middle Name", :field_type => "short_answer"})
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
      line.stations.first.form.form_fields[2].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[2].required.should eq(true)
      line.stations.first.form.form_fields[2].form_field_params.should eql({:label => "Last Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields[3].label.should eq("Gender")
      line.stations.first.form.form_fields[3].field_type.should eq("radio_button")
      line.stations.first.form.form_fields[3].required.should eq(true)
      line.stations.first.form.form_fields[3].form_field_params.should eql({:label => "Gender", :field_type => "radio_button", :required => "true", :option_values => ["male","female"]})
    end

    it "in block DSL way without valid_type and some with valid_type" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "email", :field_type => "short_answer", :valid_type => "email",  :required => "true"})
          end
        end
      end
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.input_formats.first.name.should eql("image_url")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[0].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[0].required.should eq(true)
      line.stations.first.form.form_fields[0].form_field_params.should eql({:label => "First Name", :field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields[1].label.should eq("email")
      line.stations.first.form.form_fields[1].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[1].required.should eq(true)
      line.stations.first.form.form_fields[1].valid_type.should eq("email")
      line.stations.first.form.form_fields[1].form_field_params.should eql({:label => "email", :field_type => "short_answer", :valid_type => "email", :required => "true"})
    end

    it "in block DSL way with invalid form_field data" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.type.should eql("WorkStation")
      line.stations.first.form.form_fields.first.errors.should eql(["Label can't be blank"])
    end

    it "in plain Ruby way with invalid form_field data" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
      line.input_formats input_format

      station = CF::Station.new({:type => "work"})
      line.stations station

      worker = CF::HumanWorker.new({:number => 1, :reward => 20})
      line.stations.first.worker = worker

      form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
      line.stations.first.form = form

      form_fields_1 = CF::FormField.new({:field_type => "short_answer", :required => "true"})
      line.stations.first.form.form_fields form_fields_1

      line.stations.first.type.should eql("WorkStation")
      line.stations.first.form.form_fields.first.errors.should eql(["Label can't be blank"])
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
      line.stations.first.form.form_fields.first.to_s.should eql("{:id => => #{line.stations.first.form.form_fields.first.id}, :label => First Name, :field_type => short_answer, :required => true, :errors => }")
    end
  end
end