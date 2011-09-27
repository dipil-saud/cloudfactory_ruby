require 'spec_helper'

describe CF::Line do
  let(:input_format) { CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"}) }

  context "create a line" do
    it "the plain ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => false, :description => "this is description"})
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
    end

    it "using block with variable" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::InputFormat.new({:line => l, :name => "image", :required => true, :valid_type => "url"})
        CF::Station.new({:line => l, :type => "work"}) 
      end
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.input_formats[0].name.should eql("image_url")
      line.input_formats[1].name.should eql("image")
      line.stations.first.type.should eq("WorkStation")
    end

    it "using block without variable" do
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
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.input_formats.first.name.should eql("image_url")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields.first.label.should eq("First Name")
    end

    it "with all the optional params" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => true, :description => "this is description"})
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.public.should eql(true)
      line.description.should eq("this is description")
    end
  end

  context "with 1 station" do
    it "create with a new station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |station|
          CF::HumanWorker.new({:line => l, :station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.title.should eq(title)
      line.department_name.should eq("Digitization")
      line.input_formats.first.name.should eql("image_url")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.worker.reward.should eq(20)
      line.stations.first.form.title.should eq("Enter text from a business card image")
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields.first.label.should eq("First Name")
      line.stations.first.form.form_fields.first.field_type.should eq("short_answer")
      line.stations.first.form.form_fields.first.required.should eq(true)
    end
  end

  context "listing lines" do
    it "should list all the existing lines that belong to particular owner" do
      WebMock.allow_net_connect!
      5.times do |i|
        title_i = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        CF::Line.new(title_i, "Digitization", {:public => false, :description => "#{i}-this is description"})
      end
      lines = CF::Line.all
      lines.class.should eql(Hash)
    end

    it "should list all the public lines" do
      WebMock.allow_net_connect!
      title_0 = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      title_10 = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      title_11 = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      CF::Line.new(title_0, "Digitization", {:public => false, :description => "this is description"})
      CF::Line.new(title_10, "Digitization", {:public => true, :description => "this is description"})
      CF::Line.new(title_11, "Digitization", {:public => true, :description => "this is description"})
      lines = CF::Line.public_lines(:page => "all")
      lines.map {|l| l['title'] }.join(",").should include(title_11)
    end
  end

  context "an existing line" do
    it "should get the line info by passing the line object" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => true, :description => "this is description"})
      get_line = CF::Line.info(line)
      get_line['title'].should eql(title)
      get_line['public'].should eql(true)
      get_line['description'].should eql("this is description")
    end

    it "should get the line info by passing just the title" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => true, :description => "this is description"})
      get_line = CF::Line.info(line.title)
      get_line['title'].should eql(title)
      get_line['public'].should eql(true)
      get_line['description'].should eql("this is description")
    end

    it "should render the error sent via the API overriding the RestClient one" do
      WebMock.allow_net_connect!
      get_line = CF::Line.info("non-existing-line-title")
      get_line['code'].should eql(404)
      get_line['error']['message'].should match("Line not found for title: non-existing-line-title under your account")
    end

  end

  context "deleting" do
    it "should delete a line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => true, :description => "this is description"})
      resp = line.destroy
      resp['code'].should eql(200)
      deleted_resp = CF::Line.info(line)
      deleted_resp['error']['message'].should eql("Line not found for title: #{title} under your account")
    end

    it "should delete a line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => true, :description => "this is description"})
      resp = CF::Line.destroy(title)
      resp['code'].should eql(200)
      deleted_resp = CF::Line.info(line)
      deleted_resp['error']['message'].should eql("Line not found for title: #{title} under your account")
    end
  end

  context "create a basic line" do
    it "should create a basic line with one station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line.title.should eq(title)
      line.input_formats.first.name.should eql("image_url")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.worker.reward.should eq(20)
      line.stations.first.form.title.should eq("Enter text from a business card image")
      line.stations.first.form.instruction.should eq("Describe")
      line.stations.first.form.form_fields[0].label.should eq("First Name")
      line.stations.first.form.form_fields[0].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[0].required.should eq(true)
      line.stations.first.form.form_fields[1].label.should eq("Middle Name")
      line.stations.first.form.form_fields[1].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[1].required.should eq(nil)
      line.stations.first.form.form_fields[2].label.should eq("Last Name")
      line.stations.first.form.form_fields[2].field_type.should eq("short_answer")
      line.stations.first.form.form_fields[2].required.should eq(true)
    end
  end

  context "create line using plain ruby way" do
    it "should create a station " do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "work"})
      line.stations station
      line.stations.first.type.should eql("WorkStation")
    end

    it "should create a human worker within station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "work"})
      line.stations station
      worker = CF::HumanWorker.new({:number => 1, :reward => 20})
      line.stations.first.worker = worker
      line.stations.first.type.should eql("WorkStation")
      line.stations.first.worker.number.should eql(1)
      line.stations.first.worker.reward.should eql(20)
    end

    it "should create a TaskForm within station" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
      station = CF::Station.new({:type => "work"})
      line.stations station

      worker = CF::HumanWorker.new({:number => 1, :reward => 20})
      line.stations.first.worker = worker

      form = CF::TaskForm.new({:title => "Enter text from a business card image", :instruction => "Describe"})
      line.stations.first.form = form

      line.stations.first.form.title.should eql("Enter text from a business card image")
      line.stations.first.form.instruction.should eql("Describe")
    end

    it "should create an input_format within line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
      line.input_formats input_format
      station = CF::Station.new({:type => "work"})
      line.stations station
      line.input_formats.first.name.should eq("image_url")
      line.input_formats.first.required.should eq(true)
      line.input_formats.first.valid_type.should eq("url")
    end

    it "should create form fields within the standard instruction" do
      WebMock.allow_net_connect!
      sleep 1
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      line = CF::Line.new(title, "Digitization")
      CF::InputFormat.new({:line => line, :name => "image_url", :required => true, :valid_type => "url"})
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

  context "create a line" do
    it "the plain ruby way" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization")
      line_1 = CF::Line.new(title, "Digitization")
      line_1.errors.should eql(["Title is already taken for this account"])
    end
  end

  context "delete line whose production run is already created" do
    it "it should throw error and must be deleted if forced true is passed" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true})
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

      run = CF::Run.create(line, "run-#{title}", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
      delete = CF::Line.destroy(title)
      delete['error']['message'].should eql("Cannot delete line. You have production runs using this line. Pass force option to enforce deletion.")
      delete['code'].should_not eql(200)

      forced_delete = CF::Line.destroy(title, :forced => true)

      search_line = CF::Line.find(title)
      search_line['code'].should eql(404)
      search_line['error']['message'].should eql("Line not found for title: #{title} under your account")
    end
  end

  context "returns all the associated elements of line" do
    it "it give details of line" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line_details = CF::Line.inspect(title)
      line_input_format_id = line_details['input_formats'].first['id']
      worker_id = line_details['stations'].first['worker']['id']
      form_field_id = line_details['stations'].first['form_fields'].first['id']
      station_input_format_id = line_details['stations'].first['input_formats'].first['id']
      line_details.should eql({"title"=>"#{title}", "description"=>"", "department"=>"Digitization", "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"Company", "required"=>true, "valid_type"=>nil}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"id"=>"#{worker_id}", "number"=>1, "reward"=>20, "type"=>"HumanWorker", "stat_badge"=>{"abandonment_rate"=>30, "approval_rating"=>80, "country"=>nil, "adult"=>nil}, "skill_badge"=>nil}, "form"=>{"title"=>"Enter text from a business card image", "instruction"=>"Describe"}, "form_fields"=>[{"id"=>"#{form_field_id}", "label"=>"First Name", "field_type"=>"short_answer", "hint"=>nil, "required"=>true, "unique"=>nil, "hide_label"=>nil, "value"=>nil}], "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"Company", "required"=>true, "valid_type"=>nil}]}]})
    end

    it "for robot worker" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "text", :required => "true"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::RobotWorker.create({:station => s, :type => "entity_extraction_robot", :settings => {:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]}})
        end
      end
      line_details = CF::Line.inspect(title)
      line_input_format_id = line_details['input_formats'].first['id']
      station_input_format_id = line_details['stations'].first['input_formats'].first['id']
      worker_id = line_details['stations'].first['worker']['id']
      line_details.should eql({"title"=>"#{title}", "description"=>"", "department"=>"Digitization", "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"text", "required"=>true, "valid_type"=>nil}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"id"=>"#{worker_id}", "number"=>1, "reward"=>0.5, "type"=>"EntityExtractionRobot"}, "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"text", "required"=>true, "valid_type"=>nil}]}]})
    end

    it "with skill test feature" do
      WebMock.allow_net_connect!
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
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 2
      line = CF::Line.create(title, "Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
        CF::Station.create({:line =>l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20, :skill_badge => badge})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      line_details = CF::Line.inspect(title)
      line_input_format_id = line_details['input_formats'].first['id']
      station_input_format_id = line_details['stations'].first['input_formats'].first['id']
      form_field_id = line_details['stations'].first['form_fields'].first['id']
      worker_id = line_details['stations'].first['worker']['id']
      line_details.should eql({"title"=>"#{title}", "description"=>"", "department"=>"Digitization", "code"=>200, "input_formats"=>[{"id"=>"#{line_input_format_id}", "name"=>"image_url", "required"=>true, "valid_type"=>"url"}], "stations"=>[{"index"=>1, "type"=>"WorkStation", "worker"=>{"id"=>"#{worker_id}", "number"=>1, "reward"=>20, "type"=>"HumanWorker", "stat_badge"=>{"abandonment_rate"=>30, "approval_rating"=>80, "country"=>nil, "adult"=>nil}, "skill_badge"=>nil}, "form"=>{"title"=>"Enter text from a business card image", "instruction"=>"Describe"}, "form_fields"=>[{"id"=>"#{form_field_id}", "label"=>"First Name", "field_type"=>"short_answer", "hint"=>nil, "required"=>true, "unique"=>nil, "hide_label"=>nil, "value"=>nil}], "input_formats"=>[{"id"=>"#{station_input_format_id}", "name"=>"image_url", "required"=>true, "valid_type"=>"url"}]}]})
    end

    it "should get all lines with pagination" do
      WebMock.allow_net_connect!
      line = CF::Line.all(:page => 1)
      line.class.should eql(Hash)
    end

    it "should get all lines with pagination all" do
      WebMock.allow_net_connect!
      25.times do |i|
        title_i = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        CF::Line.new(title_i, "Digitization", {:public => true, :description => "#{i}-this is description"})
      end
      line = CF::Line.all(:page => "all")
      line['total_pages'].should eql(1)
      line['lines'].class.should eql(Array)
    end
  end

  context "get a line of other account" do
    it "as public line" do
      WebMock.allow_net_connect!
      CF.configure do |config|
        config.api_key = "1d38e382894338beda100736808f5a06083063e2"
        config.account_name = "hero"
      end
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title, "Digitization") do
        CF::InputFormat.new({:line => self, :name => "text", :required => true})
        CF::Station.create({:line => self, :type => "work"}) do |station|
          CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => station, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
      end
      got_line = CF::Line.find("hero/#{title}")
      got_line['title'].should eql("#{title}")
      got_line['public'].should eql(true)
      CF.configure do |config|
        config.account_name = API_CONFIG['account_name']
        config.api_version = API_CONFIG['api_version']
        config.api_url = API_CONFIG['api_url']
        config.api_key = API_CONFIG['api_key']
      end
      run = CF::Run.create("hero/#{title}", "run-#{title}", [{"text" => "run for public line of another account"}])
      run.title.should eql("run-#{title}")
      run.input.should eql([{"text" => "run for public line of another account"}])
    end

    it "as private line" do
      WebMock.allow_net_connect!
      CF.configure do |config|
        config.api_key = "1d38e382894338beda100736808f5a06083063e2"
        config.account_name = "hero"
      end
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.new(title, "Digitization", {:public => false, :description => "this is description"})
      CF.configure do |config|
        config.account_name = API_CONFIG['account_name']
        config.api_version = API_CONFIG['api_version']
        config.api_url = API_CONFIG['api_url']
        config.api_key = API_CONFIG['api_key']
      end
      got_line = CF::Line.find("hero/#{title}")
      got_line['code'].should eql(404)
      got_line['error']['message'].should eql("Line with title: #{title} under account hero is not public")
    end
  end

  context "create line with output format" do
    it "should create in block Dsl way with two stations" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
        CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 10})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "Address", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Mobile", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Email", :field_type => "email", :required => "true"})
          end
        end
        CF::OutputFormat.new({:line => l, :station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
      end
      line.title.should eq(title)
      line.input_formats.first.name.should eql("Company")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.worker.reward.should eq(10)
      line.output_formats.settings.should eql({:station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
    end

    it "should create in plain ruby way with two stations" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
        CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 10})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "First Name", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Middle Name", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Last Name", :field_type => "short_answer", :required => "true"})
          end
        end
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          CF::TaskForm.create({:station => s, :title => "Enter text from a business card image", :instruction => "Describe"}) do |i|
            CF::FormField.new({:form => i, :label => "Address", :field_type => "short_answer", :required => "true"})
            CF::FormField.new({:form => i, :label => "Mobile", :field_type => "short_answer"})
            CF::FormField.new({:form => i, :label => "Email", :field_type => "email", :required => "true"})
          end
        end
      end
      output_format = CF::OutputFormat.new({:station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
      line.output_formats output_format
      line.title.should eq(title)
      line.input_formats.first.name.should eql("Company")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.worker.reward.should eq(10)
      line.output_formats.settings.should eql({:station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
    end

    it "should through error if line is incomplete" do
      WebMock.allow_net_connect!
      title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
      sleep 1
      line = CF::Line.create(title,"Digitization") do |l|
        CF::InputFormat.new({:line => l, :name => "Company", :required => true, :valid_type => "general"})
        CF::InputFormat.new({:line => l, :name => "Website", :required => true, :valid_type => "url"})
        CF::Station.create({:line => l, :type => "work"}) do |s|
          CF::HumanWorker.new({:station => s, :number => 1, :reward => 10})
        end
        CF::OutputFormat.new({:line => l, :station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
      end
      line.title.should eq(title)
      line.input_formats.first.name.should eql("Company")
      line.stations.first.type.should eq("WorkStation")
      line.stations.first.worker.number.should eq(1)
      line.stations.first.worker.reward.should eq(10)
      line.output_formats.errors.should eql("Line is not complete or valid")
    end
  end
end