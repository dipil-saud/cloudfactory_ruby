require 'spec_helper'

module CF
  describe CF::Run do
    context "create a new run" do
      it "for a line in block dsl way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
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

        run = CF::Run.create(line, "run-#{title}", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

        line.title.should eq(title)

        line.input_formats.first.name.should eq("Company")
        line.input_formats.first.required.should eq(true)

        line.stations[0].type.should eq("WorkStation")

        line.stations[0].worker.number.should eq(1)
        line.stations[0].worker.reward.should eq(20)

        line.stations[0].form.title.should eq("Enter text from a business card image")
        line.stations[0].form.instruction.should eq("Describe")

        line.stations[0].form.form_fields[0].label.should eq("First Name")
        line.stations[0].form.form_fields[0].field_type.should eq("short_answer")
        line.stations[0].form.form_fields[0].required.should eq(true)

        run.title.should eq("run-#{title}")
        runfile = File.read(run.file)
        runfile.should == File.read(File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
      end

      it "should create a production run for input data as Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
        run.input.should eql( [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
      end

      it "for an existing line" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
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
        run = CF::Run.create(line,"run-#{title}", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        run.title.should eq("run-#{title}")
      end

      it "just using line title" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
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
        run = CF::Run.create(title, "run-#{title}", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))
        run.title.should eq("run-#{title}")
      end

      it "for a line in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title, "Digitization")
        input_format_1 = CF::InputFormat.new({:name => "Company", :required => true})
        input_format_2 = CF::InputFormat.new({:name => "Website", :required => true, :valid_type => "url"})
        line.input_formats input_format_1
        line.input_formats input_format_2

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

        run = CF::Run.create(line, "run-#{title}", File.expand_path("../../fixtures/input_data/test.csv", __FILE__))

        line.title.should eq(title)
        line.stations.first.type.should eq("WorkStation")

        line.input_formats[0].name.should eq("Company")
        line.input_formats[0].required.should eq(true)
        line.input_formats[1].name.should eq("Website")
        line.input_formats[1].required.should eq(true)

        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.reward.should eql(20)

        line.stations.first.form.title.should eql("Enter text from a business card image")
        line.stations.first.form.instruction.should eql("Describe")

        line.stations.first.form.form_fields[0].label.should eql("First Name")
        line.stations.first.form.form_fields[0].field_type.should eql("short_answer")
        line.stations.first.form.form_fields[0].required.should eql(true)
        line.stations.first.form.form_fields[1].label.should eql("Middle Name")
        line.stations.first.form.form_fields[1].field_type.should eql("short_answer")
        line.stations.first.form.form_fields[2].label.should eql("Last Name")
        line.stations.first.form.form_fields[2].field_type.should eql("short_answer")
        line.stations.first.form.form_fields[2].required.should eql(true)
      end

      it "should fetch result" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        output = run.final_output
        output.first['keyword_relevance_of_url'].should eql([96.7417, 57.3763, 56.8721, 54.6844, 17.7066])
        output.first['keywords_of_url'].should eql(["tech startup thing", "nights", "Nepal", "Canada", "U.S."])
      end

      it "should fetch result of the specified station with run title" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
          end
          CF::Station.create({:line => l, :type => "work"}) do |s1|
            CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj", "iPhone"]}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}, {"url"=> "http://techcrunch.com/2011/07/26/buddytv-iphone/"}])
        sleep 30
        output = run.final_output
        output.first['included_keywords_count_in_contents_of_url'].should eql(["3", "2", "2"])
        output.first['keyword_included_in_contents_of_url'].should eql(["SaaS", "see", "additional"])
        output.last['included_keywords_count_in_contents_of_url'].should eql(["4"])
        output.last['keyword_included_in_contents_of_url'].should eql(["iPhone"])
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
        line.stations.first.worker.type.should eql("TextExtractionRobot")
        line.stations.last.worker.class.should eql(CF::RobotWorker)
        line.stations.last.worker.reward.should eql(0.5)
        line.stations.last.worker.number.should eql(1)
        line.stations.last.worker.settings.should eql({:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj", "iPhone"]})
        line.stations.last.worker.type.should eql("KeywordMatchingRobot")
        output_of_station_1 = CF::Run.output({:title => "run-#{title}", :station => 1})
        output_of_station_2 = CF::Run.output({:title => "run-#{title}", :station => 2})
        opt = output_of_station_2.map{|o| o['keyword_included_in_contents_of_url']}.join(",")
        opt.should include("SaaS", "see", "additional", "iPhone")
      end

      it "should create production run with invalid input_format for input" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url_1"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        run.errors.should eql(["Extra Headers in file: [url_1]", "Insufficient Headers in file: [url]"])
      end

      it "should create production run with invalid data" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", File.expand_path("../../fixtures/input_data/media_converter_robot.csv", __FILE__))
        run.errors.should eql(["Extra Headers in file: [url_1]", "Insufficient Headers in file: [url]"])
      end

      it "should create production run with used title data" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        run_1 = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        run_1.errors.should eql(["Title is already taken for this account"])
      end

      it "should create production run and find created run" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        sleep 10
        found_run = CF::Run.find("run-#{title}")
        found_run['code'].should eql(200)
        found_run['title'].should eql("run-#{title}")
        found_run['line']['title'].should eql(title)
        found_run['line']['department'].should eql("Digitization")
        found_run['status'].should eql("completed")
      end

      it "should create production run and try to find run with unused title" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        found_run = CF::Run.find("unused_title")
        found_run['code'].should eql(404)
        found_run['errors'].should eql("Run document not found using selector: {:title=>\"unused_title\"}")
      end
    end

    context "check run progress and resume run" do
      it "should check the progress" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        progress = run.progress
        progress_1 = CF::Run.progress("run-#{title}")
        progress.should eql(progress_1)
        progress['progress'].should eql(100)
      end

      it "should get the progress details" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        progress = run.progress_details
        progress_1 = CF::Run.progress_details("run-#{title}")
        progress.should eql(progress_1)
        progress['total']['progress'].should eql(100)
        progress['total']['units'].should eql(1)
      end

      it "should get the progress details for multiple stations" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "text_extraction_robot", :settings => {:url => ["{{url}}"]}})
          end
          CF::Station.create({:line => l, :type => "work"}) do |s1|
            CF::RobotWorker.create({:station => s1, :type => "keyword_matching_robot", :settings => {:content => ["{{contents_of_url}}"], :keywords => ["SaaS","see","additional","deepak","saroj"]}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://techcrunch.com/2011/07/26/with-v2-0-assistly-brings-a-simple-pricing-model-rewards-and-a-bit-of-free-to-customer-service-software"}])
        sleep 30
        progress = run.progress_details
        progress_1 = CF::Run.progress_details("run-#{title}")
        progress.should eql(progress_1)
        progress['total']['progress'].should eql(100)
        progress['total']['units'].should eql(1)
      end
    end

    context "get run" do
      it "should return all the runs for an account" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        line_1 = CF::Line.create("#{title}_1","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run_1 = CF::Run.create(line_1, "run-#{title}_1", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        line_2 = CF::Line.create("#{title}_2","Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run_2 = CF::Run.create(line_2, "run-#{title}_2", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        got_run = CF::Run.all
        got_run['runs'].class.should eql(Array)
        got_run['runs'].first['status'].should eql("completed")
      end

      it "should return all the runs for a line" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        run_1 = CF::Run.create(line, "run-#{title}_1", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        run_2 = CF::Run.create(line, "run-#{title}_2", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        got_run = CF::Run.all({:line_title => "#{title}"})
        run_titles = got_run['runs'].map {|r| r['title']}.join(",")
        run_titles.should include("run-#{title}", "run-#{title}_1", "run-#{title}_2")
      end

      it "should get all runs with pagination" do
        WebMock.allow_net_connect!
        run = CF::Run.all({:page => 1})
        run['runs'].class.should eql(Array)
        run['code'].should eql(200)
      end

      it "should get all runs with pagination params all" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          end
        end
        3.times do |i|
          CF::Run.create(line, "run-#{title}_#{i}", [{"url"=> "http://www.sprout-technology.com"}])
          sleep 10
        end
        run = CF::Run.all({:page => "all"})
        run['runs'].class.should eql(Array)
        run_title = run['runs'].map {|r| r['title']}.join(",")
        3.times do |i|
          run_title.should include("run-#{title}_#{i}")
        end
      end
    end

    context "create a run with insufficient balance and" do
      it "should resume run" do
        VCR.use_cassette "run/block/resume-run", :record => :new_episodes do
          # WebMock.allow_net_connect!
          # change account available_balance to 10 cents
          line = CF::Line.create("resume_run_line","Digitization") do |l|
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
          run = CF::Run.create(line, "resume_run", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"},{"Company"=>"Google","Website"=>"google.com"}])
          # debugger
          # Change account available_balance to 200000 cents
          resumed_run = CF::Run.resume("resume_run")
          resumed_run['code'].should eql(200)
          resumed_run['status'].should eql("resumed")
          resumed_run['title'].should eql("resume_run")
        end
      end
    end

    context "creation of run by adding units" do
      it "should manually add units" do
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"}])
        sleep 10
        added_units = CF::Run.add_units(:run_title => "run-#{title}", :units => [{"Company"=>"Apple,Inc","Website"=>"Apple.com"}, {"Company"=>"Sprout","Website"=>"sprout.com"}])
        added_units['successfull'].should eql("Sucessfully added 2 units, Failed :0")
        run.title.should eql("run-#{title}")
      end

      it "should add units by passing file" do
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Sprout","Website"=>"sprout.com"}])
        sleep 10
        added_units = CF::Run.add_units({:run_title => "run-#{title}", :file => File.expand_path("../../fixtures/input_data/test.csv", __FILE__)})
        added_units['successfull'].should eql("Sucessfully added 1 units, Failed :0")
        run.title.should eql("run-#{title}")
      end

      it "should throw errors for invalid input while adding units" do
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"}])
        added_units = CF::Run.add_units(:run_title => "run-#{title}", :units => [{"Company"=>"Sprout","Url"=>"sprout.com"}])
        added_units['error']['message'].should eql(["Extra Headers in file: [url]", "Insufficient Headers in file: [website]"])
        run.title.should eql("run-#{title}")
      end

      it "should throw errors for empty input while adding units" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"}])
        added_units = CF::Run.add_units(:run_title => "run-#{title}", :units => [])
        added_units['error']['message'].should eql("Run document not found using selector: {:title=>\"run-#{title}\"}")
      end
    end

    context "Delete Run" do
      it "should call destroy method of run to delete a created run" do
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
        run = CF::Run.create(line, "run-#{title}", [{"Company"=>"Apple,Inc","Website"=>"Apple.com"}])
        sleep 10
        deleted_resp = CF::Run.destroy("run-#{title}")
        deleted_resp['code'].should eql(200)
        deleted_resp['line']['title'].should eql(title)
        deleted_resp['title'].should eql("run-#{title}")
      end

      it "should throw error message while deleting uncreated Run" do
        delete = CF::Run.destroy("norun")
        delete['code'].should_not eql(200)
        delete['error']['message'].should eql("Run document not found using selector: {:title=>\"norun\"}")
      end
    end
  end
end