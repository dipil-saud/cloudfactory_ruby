# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a Term Extraction robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/term_extraction_robot/block/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.create("term_extraction","Digitization") do |l|
            CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
            CF::Station.create({:line => l, :type => "work"}) do |s|
              CF::RobotWorker.create({:station => s, :settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
            end
          end
          run = CF::Run.create(line, "term_extraction_run", [{"url"=> "http://www.sprout-technology.com"}])
          # sleep 20
          output = run.final_output
          output.first['keyword_relevance_of_url'].should eql([96.7417, 57.3763, 56.8721, 54.6844, 17.7066])
          output.first['keywords_of_url'].should eql(["tech startup thing", "nights", "Nepal", "Canada", "U.S."])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true})
          line.stations.first.worker.type.should eql("TermExtractionRobot")
        end
      end

      it "should create content_scraping_robot worker for first station in plain ruby way" do
        # WebMock.allow_net_connect!
        VCR.use_cassette "robot_worker/term_extraction_robot/plain-ruby/create-worker-single-station", :record => :new_episodes do
          line = CF::Line.new("term_extraction_1","Digitization")
          input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
          line.input_formats input_format

          station = CF::Station.new({:type => "work"})
          line.stations station

          worker =  CF::RobotWorker.create({:settings => {:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true}, :type => "term_extraction_robot"})
          line.stations.first.worker = worker

          run = CF::Run.create(line, "term_extraction_run_1", [{"url"=> "http://www.sprout-technology.com"}])
          # sleep 20
          output = run.final_output
          output.first['keyword_relevance_of_url'].should eql([96.7417, 57.3763, 56.8721, 54.6844, 17.7066])
          output.first['keywords_of_url'].should eql(["tech startup thing", "nights", "Nepal", "Canada", "U.S."])
          line.stations.first.worker.class.should eql(CF::RobotWorker)
          line.stations.first.worker.reward.should eql(0.5)
          line.stations.first.worker.number.should eql(1)
          line.stations.first.worker.settings.should eql({:url => ["{{url}}"], :max_retrieve => 5, :show_source_text => true})
          line.stations.first.worker.type.should eql("TermExtractionRobot")
        end
      end
    end
  end
end