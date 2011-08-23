require 'spec_helper'

describe CF::Line do
  let(:input_format) { CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"}) }

  context "create a line" do
    it "the plain ruby way" do
      VCR.use_cassette "lines/block/create", :record => :new_episodes do
        # WebMock.allow_net_connect!
        line = CF::Line.new("Digit-02", "Digitization", {:public => false, :description => "this is description"})
        line.title.should eq("Digit-02")
        line.department_name.should eq("Digitization")
      end
    end

    it "using block with variable" do
      VCR.use_cassette "lines/block/create-block-var", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Digitizecard-10","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
          CF::Station.new({:line => l, :type => "work"}) 
        end
        line.title.should eq("Digitizecard-10")
        line.department_name.should eq("Digitization")
        line.input_formats[0].name.should eql("image_url")
        line.input_formats[1].name.should eql("image")
        line.stations.first.type.should eq("WorkStation")
      end
    end

    it "using block without variable" do
      VCR.use_cassette "lines/block/create-without-block-var", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Digitizeard", "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitizeard")
        line.department_name.should eq("Digitization")
        line.input_formats.first.name.should eql("image_url")
        line.stations.first.type.should eq("WorkStation")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields.first.label.should eq("First Name")
      end
    end

    it "with all the optional params" do
      VCR.use_cassette "lines/block/create-optional-params", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.new("Lineame", "Digitization", {:public => true, :description => "this is description"})
        line.title.should eq("Lineame")
        line.department_name.should eq("Digitization")
        line.public.should eql(true)
        line.description.should eq("this is description")
      end
    end
  end

  context "with 1 station" do
    it "create with a new station" do
      VCR.use_cassette "lines/block/create-one-station", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("Digitizer1", "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => l, :type => "work"}) do |station|
            CF::HumanWorker.new({:line => l, :station => station, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digitizer1")
        line.department_name.should eq("Digitization")
        line.input_formats.first.name.should eql("image_url")
        line.stations.first.type.should eq("WorkStation")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields.first.label.should eq("First Name")
        line.stations.first.form.form_fields.first.field_type.should eq("SA")
        line.stations.first.form.form_fields.first.required.should eq("true")
      end
    end
  end

  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/listing-lines", :record => :new_episodes do
        5.times do |i|
          CF::Line.new("Digitizeard---#{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        lines = CF::Line.all
        lines.last['title'].should eq("digitizeard---4")
      end
    end

    it "should list all the public lines" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/listing-public-lines", :record => :new_episodes do
        1.times do |i|
          CF::Line.new("Digitizecarr-#{i}", "Digitization", {:public => false, :description => "#{i}-this is description"})
        end
        2.times do |i|
          CF::Line.new("Lineee-#{i}", "Digitization", {:public => true, :description => "#{i}-this is description"})
        end

        lines = CF::Line.public_lines
        lines.last.title.should eq("lineee-1")
      end
    end
  end

  context "an existing line" do
    it "should get the line info by passing the line object" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/line-info", :record => :new_episodes do
        line = CF::Line.new("Digitize-22", "Digitization", {:public => true, :description => "this is description"})
        get_line = CF::Line.info(line)
        get_line.title.should eql("digitize-22")
        get_line.public.should eql(true)
        get_line.description.should eql("this is description")
      end
    end
    
    it "should get the line info by passing just the title" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/line-info-title", :record => :new_episodes do
        line = CF::Line.new("digitizee", "Digitization", {:public => true, :description => "this is description"})
        get_line = CF::Line.info(line.title)
        get_line.title.should eql("digitizee")
        get_line.public.should eql(true)
        get_line.description.should eql("this is description")
      end
    end

    it "should render the error sent via the API overriding the RestClient one" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/non-existing-line", :record => :new_episodes do
        get_line = CF::Line.info("non-existing-line-title")
        get_line.code.should eql(404)
        get_line.error.message.should match("Line document not found using selector")
      end
    end

  end

  context "deleting" do
    it "should delete a line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/delete-line", :record => :new_episodes do
        line = CF::Line.new("Digitizerd-2", "Digitization", {:public => true, :description => "this is description"})
        resp = line.destroy
        resp.code.should eql(200)
        deleted_resp = CF::Line.info(line)
        deleted_resp.error.message.should eql("Line document not found using selector: {:public=>true, :title=>\"digitizerd-2\"}")
      end
    end
    
    it "should delete a line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/delete-line-with-title", :record => :new_episodes do
        line = CF::Line.new("Digitizerd-2", "Digitization", {:public => true, :description => "this is description"})
        resp = CF::Line.destroy("Digitizerd-2")
        resp.code.should eql(200)
        deleted_resp = CF::Line.info(line)
        deleted_resp.error.message.should eql("Line document not found using selector: {:public=>true, :title=>\"digitizerd-2\"}")
      end
    end
  end

  context "create a basic line" do
    it "should create a basic line with one station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/block/create-basic-line", :record => :new_episodes do
        line = CF::Line.create("Digiard-11","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 2, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "SA", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "SA"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "SA", :required => "true"})
            end
          end
        end
        line.title.should eq("Digiard-11")
        line.input_formats.first.name.should eql("image_url")
        line.stations.first.type.should eq("WorkStation")
        line.stations.first.worker.number.should eq(2)
        line.stations.first.worker.reward.should eq(20)
        line.stations.first.form.title.should eq("Enter text from a business card image")
        line.stations.first.form.instruction.should eq("Describe")
        line.stations.first.form.form_fields[0].label.should eq("First Name")
        line.stations.first.form.form_fields[0].field_type.should eq("SA")
        line.stations.first.form.form_fields[0].required.should eq("true")
        line.stations.first.form.form_fields[1].label.should eq("Middle Name")
        line.stations.first.form.form_fields[1].field_type.should eq("SA")
        line.stations.first.form.form_fields[1].required.should eq(nil)
        line.stations.first.form.form_fields[2].label.should eq("Last Name")
        line.stations.first.form.form_fields[2].field_type.should eq("SA")
        line.stations.first.form.form_fields[2].required.should eq("true")
      end
    end
  end

  context "create line using plain ruby way" do
    it "should create a station " do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-station", :record => :new_episodes do
        line = CF::Line.new("Digitizeardd7", "Digitization")
        CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.stations.first.type.should eql("WorkStation")
      end
    end

    it "should create a human worker within station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-station-with-worker", :record => :new_episodes do
        line = CF::Line.new("Digitize-card6", "Digitization")
        CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
        station = CF::Station.new({:type => "work"})
        line.stations station
        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.number.should eql(2)
        line.stations.first.worker.reward.should eql(20)
      end
    end

    it "should create a TaskForm within station" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-form", :record => :new_episodes do
        line = CF::Line.new("Diggard-1", "Digitization")
        CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker

        form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
        line.stations.first.form = form
        
        line.stations.first.form.title.should eql("Enter text from a business card image")
        line.stations.first.form.instruction.should eql("Describe")
      end
    end

    it "should create an input_format within line" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-input-header", :record => :new_episodes do
        line = CF::Line.new("Digard-2", "Digitization")
        input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.input_formats input_format
        station = CF::Station.new({:type => "work"})
        line.stations station
        line.input_formats.first.name.should eq("image_url")
        line.input_formats.first.required.should eq(true)
        line.input_formats.first.valid_type.should eq("url")
      end
    end

    it "should create form fields within the standard instruction" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-form-fields", :record => :new_episodes do
        line = CF::Line.new("Digitized-4", "Digitization")
        CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 2, :reward => 20})
        line.stations.first.worker = worker

        form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
        line.stations.first.form = form

        form_fields_1 = CF::FormField.new({:label => "First Name", :field_type => "short_answer", :required => "true"})
        line.stations.first.form.form_fields form_fields_1
        form_fields_2 = CF::FormField.new({:label => "Middle Name", :field_type => "short_answer"})
        line.stations.first.form.form_fields form_fields_2
        form_fields_3 = CF::FormField.new({:label => "Last Name", :field_type => "short_answer", :required => "true"})
        line.stations.first.form.form_fields form_fields_3

        line.stations.first.form.form_fields[0].label.should eql("First Name")
        line.stations.first.form.form_fields[0].field_type.should eq("short_answer")
        line.stations.first.form.form_fields[0].required.should eq(true)
        line.stations.first.form.form_fields[1].label.should eql("Middle Name")
        line.stations.first.form.form_fields[1].field_type.should eq("short_answer")
        line.stations.first.form.form_fields[2].label.should eql("Last Name")
        line.stations.first.form.form_fields[2].field_type.should eq("short_answer")
        line.stations.first.form.form_fields[2].required.should eq(true)
      end
    end
  end
  
  context "create a line" do
    it "the plain ruby way" do
      # WebMock.allow_net_connect!
      VCR.use_cassette "lines/plain-ruby/create-line-with-used-title", :record => :new_episodes do
        line = CF::Line.new("new_line", "Digitization")
        line_1 = CF::Line.new("new_line", "Digitization")
        line_1.errors.should eql(["Title is already taken for this account"])
      end
    end
  end
  
  context "delete line whose production run is already created" do
    it "it should throw error and must be deleted if forced true is passed" do
      VCR.use_cassette "lines/block/delete-line-of-active-run", :record => :new_episodes do
        # WebMock.allow_net_connect!
        line = CF::Line.create("delete_line_of_run","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
          CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
              CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
              CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
            end
          end
        end

        run = CF::Run.create(line, "delete_line_of_run_run", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        
        delete = CF::Line.destroy("delete_line_of_run")
        delete.error.message.should eql("cannot delete the line, Active runs exists. use forced delete if you still want to delete the line.")
        delete.code.should_not eql(200)
        
        forced_delete = CF::Line.destroy("delete_line_of_run", :forced => true)

        search_line = CF::Line.find("delete_line_of_run")
        search_line['code'].should eql(404)
        search_line['error']['message'].should eql("Line document not found using selector: {:public=>true, :title=>\"delete_line_of_run\"}")
      end
    end
  end
  
  context "returns all the associated elements of line" do
    it "it give details of line" do
      VCR.use_cassette "lines/block/line-details", :record => :new_episodes do
        # WebMock.allow_net_connect!
        line = CF::Line.create("line_details","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            end
          end
        end
        line_details = CF::Line.inspect("line_details")
        line_input_format_id = line_details['input_formats'].first['id']
        form_field_id = line_details['stations'].first['form_fields'].first['id']
        station_input_format_id = line_details['stations'].first['input_formats'].first['id']
        line_details.should eql({"title"=>"line_details", "description"=>"", "public"=>false, "department"=>{"name"=>"Digitization"}, "app"=>{"name"=>"default", "email"=>"manish.das@sprout-technology.com", "notification_url"=>"http://www.cloudfactory.com"}, "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"Company", "required"=>true, "valid_type"=>"general", "source_station_index"=>0}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"number"=>1, "reward"=>20, "type"=>"HumanWorker", "stat_badge"=>{"approval_rating"=>80, "abandonment_rate"=>30, "country"=>nil}}, "form"=>{"title"=>"Enter text from a business card image", "instruction"=>"Describe"}, "form_fields"=>[{"id"=>"#{form_field_id}", "label"=>"First Name", "field_type"=>"short_answer", "hint"=>nil, "required"=>true, "unique"=>nil, "hide_label"=>nil, "value"=>nil}], "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"Company", "required"=>true, "valid_type"=>"general", "source_station_index"=>0}]}]})
      end
    end
    
    it "for robot worker" do
      VCR.use_cassette "lines/block/line-details_robot_worker", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.create("line_details_robot","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "text", :valid_type => "general", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "entity_extraction_robot", :settings => {:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]}})
          end
        end
        line_details = CF::Line.inspect("line_details_robot")
        line_input_format_id = line_details['input_formats'].first['id']
        station_input_format_id = line_details['stations'].first['input_formats'].first['id']
        worker_id = line_details['stations'].first['worker']['id']
        line_details.should eql({"title"=>"line_details_robot", "description"=>"", "department"=>"Digitization", "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"text", "required"=>true, "valid_type"=>"general"}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"id"=>"#{worker_id}", "number"=>1, "reward"=>0.5, "type"=>"EntityExtractionRobot"}, "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"text", "required"=>true, "valid_type"=>"general"}]}]})
      end
    end
    
    it "with skill test feature" do
      VCR.use_cassette "lines/block/line-details_skill_test", :record => :new_episodes do
      # WebMock.allow_net_connect!
        badge = 
        {
          :title => 'Football Fanatic', 
          :description => "This qualification allows you to perform work at stations which have this badge.", 
          :max_badges => 3, 
          :test => 
          {
            :input => {:name => "Lionel Andres Messi", :country => "Argentina"},
            :expected_output => 
            [{:birthplace => "Rosario, Santa Fe, Argentina",:match_options => {:tolerance => 10, :ignore_case => true }},{:position => "CF",:match_options => {:tolerance => 1 }},{:"current-club" => "Barcelona",:match_options => {:tolerance => 1, :ignore_case => false }}]
          }
        }
        line = CF::Line.create("line_details_skill_test", "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            CF::HumanWorker.new({:station => s, :number => 1, :reward => 20, :skill_badge => badge})
            CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
              CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            end
          end
        end
        line_details = CF::Line.inspect("line_details_skill_test")
        line_input_format_id = line_details['input_formats'].first['id']
        station_input_format_id = line_details['stations'].first['input_formats'].first['id']
        form_field_id = line_details['stations'].first['form_fields'].first['id']
        worker_id = line_details['stations'].first['worker']['id']
        line_details.should eql({"title"=>"line_details_skill_test", "description"=>"", "department"=>"Digitization", "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"image_url", "required"=>true, "valid_type"=>"url"}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"id"=>"#{worker_id}", "number"=>1, "reward"=>20, "type"=>"HumanWorker", "stat_badge"=>{"abandonment_rate"=>30, "approval_rating"=>80, "country"=>nil, "adult"=>nil}, "skill_badge"=>nil}, "form"=>{"title"=>"Enter text from a business card image", "instruction"=>"Describe"}, "form_fields"=>[{"id"=>"#{form_field_id}", "label"=>"First Name", "field_type"=>"short_answer", "hint"=>nil, "required"=>true, "unique"=>nil, "hide_label"=>nil, "value"=>nil}], "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"image_url", "required"=>true, "valid_type"=>"url"}]}]})
      end
    end
    
    it "should get all lines with pagination" do
      VCR.use_cassette "lines/plain-ruby/line_pagination", :record => :new_episodes do
      # WebMock.allow_net_connect!
        line = CF::Line.all(:page => 1)
        line.class.should eql(Array)
      end
    end
  end
  
  context "get a line of other account" do
    it "as public line" do
      VCR.use_cassette "lines/plain-ruby/public-line", :record => :new_episodes do
      # WebMock.allow_net_connect!
        got_line = CF::Line.find("hero/dummy")
        got_line['title'].should eql("dummy")
        got_line['public'].should eql(true)
        
        run = CF::Run.create("hero/dummy", "dummy_run", [{"text" => "run for public line of another account"}])
        run.title.should eql("dummy_run")
        run.input.should eql([{"text" => "run for public line of another account"}])
      end
    end
    
    it "as private line" do
      VCR.use_cassette "lines/plain-ruby/private-line", :record => :new_episodes do
        # WebMock.allow_net_connect!
        got_line = CF::Line.find("hero/dummy_false")
        got_line['code'].should eql(404)
        got_line['error']['message'].should eql("Line with title: dummy_false under account hero is not public")
      end
    end
  end
end