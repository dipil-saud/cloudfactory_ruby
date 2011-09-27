require 'spec_helper'

describe CF::Station do
  context "create a station" do
    it "the plain ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "work"})
      line.stations station
      line.stations.first.type.should eql("WorkStation")
    end

    it "using the block variable" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eql(1)
      line.stations.first.worker.reward.should eql(20)
      line.stations.first.form.title.should eq("Enter text from a business card image")
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
    end

    it "using without the block variable also creating instruction without block variable" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work"}) do
          CF::HumanWorker.new({:station => self, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => self, :title => "Enter text from a business card image", :instruction => "Describe"}) do
            CF::FormField.new({:form => self, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => self, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => self, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eql(1)
      line.stations.first.worker.reward.should eql(20)
      line.stations.first.form.title.should eq("Enter text from a business card image")
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
    end

    it "should create a station of Tournament station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "tournament", :jury_worker=> {:max_judges => 10, :reward => 5}, :auto_judge => {:enabled => true}}) do |s|
          CF::HumanWorker.new({:station => s, :number => 3, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.type.should eq("TournamentStation")
      line.stations.first.jury_worker.should eql({"max_judges"=>10, "confidence_level"=>0.65, "tournament_restarts"=>0, "number"=>2})
      line.stations.first.auto_judge.should eql({"enabled"=>true, "finalize_percentage"=>51})
      line.stations.first.worker.number.should eql(3)
      line.stations.first.worker.reward.should eql(20)
      line.stations.first.form.title.should eq("Enter text from a business card image")
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
    end

    it "should create a station of Improve station as first station of line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "improve"}) 
      expect { line.stations station }.to raise_error(CF::ImproveStationNotAllowed)
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
      line.stations.first.to_s.should eql("{:type => WorkStation, :index => 1, :line_title => #{title}, :station_input_formats => , :errors => }")
    end

    it "should only display the attributes which are mentioned in to_s method for tournament station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "tournament", :jury_worker=> {:max_judges => 10, :reward => 5}, :auto_judge => {:enabled => true}}) do |s|
          CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
        end
      end
      line.stations.first.to_s.should eql("{:type => TournamentStation, :index => 1, :line_title => #{title}, :station_input_formats => , :jury_worker => {\"max_judges\"=>10, \"confidence_level\"=>0.65, \"tournament_restarts\"=>0, \"number\"=>2}, auto_judge => {\"enabled\"=>true, \"finalize_percentage\"=>51}, :errors => }")
    end
  end

  context "get station" do
    it "should get information about a single station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title,"Digitization")
      line.title.should eq(title)
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new(:type => "Work")
      line.stations station
      station.type.should eq("Work")
      line.stations.first.get['type'].should eq("WorkStation")
    end

    it "should get all existing stations of a line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title,"Digitization")
      line.title.should eq(title)
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new(:type => "Work")
      line.stations station
      stations = CF::Station.all(line)
      stations.map {|s| s['type']}.join(",").should eq("WorkStation")
    end
  end

  context "create multiple station" do
    it "should create two stations using different input format" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true})
        CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work", :input_formats=> {:station_0 => [{:name => "Company"},{:name => "Website", :except => true}]}}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter the name of CEO", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end

      station = CF::Station.new(
      {:type => "work", :input_formats => {:station_0 => [{:name => "Website"}], :station_1 => [{:name => "Last Name", :except => true}]}})
      line.stations station

      worker = CF::HumanWorker.new({:number => 1, :reward => 10})
      line.stations.last.worker = worker

      form = CF::TaskForm.new({:title => "Enter the address of the given Person", :instruction => "Description"})
      line.stations.last.form = form

      form_fields_1 = CF::FormField.new({:label => "Street", :field_type => "short_answer", :required => "true"})
      line.stations.last.form.form_fields form_fields_1
      form_fields_2 = CF::FormField.new({:label => "City", :field_type => "short_answer", :required => "true"})
      line.stations.last.form.form_fields form_fields_2
      form_fields_3 = CF::FormField.new({:label => "Country", :field_type => "short_answer", :required => "true"})
      line.stations.last.form.form_fields form_fields_3
      station_1 = line.stations.first.get
      station_1['input_formats'].count.should eql(1)
      station_1['input_formats'].first['name'].should eql("Company")
      station_1['input_formats'].first['required'].should eql(true)
      station_2 = line.stations.last.get
      station_2['input_formats'].count.should eql(3)
      names = station_2['input_formats'].map {|i| i['name']}.join(",")
      required_states = station_2['input_formats'].map {|i| i['required']}.join(",")
      names.should include("Website")
      names.should include("First Name")
      names.should include("Middle Name")
      required_states.should include("true")
      required_states.should include("false") #how to make it true
      required_states.should include("false")
      station_2['input_formats'].map {|i| i['valid_type']}.join(",").should include("url")
    end
  end

  context "create a station with errors" do
    it "in plain ruby way and it should display an error message" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      station = CF::Station.new()
      line.stations station
      line.stations.first.errors.should eql("The Station type  is invalid.")
    end

    it "in block DSL way and it should display an error message" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do |l|
        CF::Station.new({:line => l})
      end
      line.stations.first.errors.should eql("The Station type  is invalid.")
    end

    it "in block DSL way without creating input_format it should display an error message" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do |l|
        CF::Station.new({:line => l, :type => "work"})
      end
      line.stations.first.errors.should eql("Input formats not assigned for the line #{line.title.downcase}")
    end

    it "Tournament station displaying errors due to invalid settings" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.new({:line => self, :type => "tournament"})
      end
      line.stations.first.type.should eq("Tournament")
      line.stations.first.errors.should eql("[\"Jury worker can't be blank\"]")
    end
  end

  context "create station with batch size option" do
    it "for work station in block DSL way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => self, :type => "work", :batch_size => 3}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.stations.first.type.should eql("WorkStation")
      line.stations.first.batch_size.should eql(3)
      line.stations.first.worker.number.should eql(1)
      line.stations.first.worker.reward.should eql(20)
    end

    it "for work station in Plain Ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "work", :batch_size => 3})
      line.stations station
      line.stations.first.type.should eql("WorkStation")
      line.stations.first.batch_size.should eql(3)
    end
  end
end