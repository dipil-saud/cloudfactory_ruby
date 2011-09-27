# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a concept tagging robot worker" do
      it "should create concept tagging robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "concept_tagging_robot", :settings => {:url => ["{{url}}"]}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=>"www.mosexindex.com"}])
        sleep 20 # require delay for final_output's processing
        output = run.final_output
        output.first['concept_tagging_of_url'].should eql(["Canada", "English language"])
        output.first['concept_tagging_relevance_of_url'].should eql([89.5153, 79.0912])
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
        line.stations.first.worker.type.should eql("ConceptTaggingRobot")
      end

      it "should create content_scraping_robot worker for first station in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::RobotWorker.create({:type => "concept_tagging_robot", :settings => {:url => ["{{url}}"]}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "run-#{title}", [{"url"=>"www.mosexindex.com"}])
        sleep 20 # require delay for final_output's processing
        output = run.final_output
        output.first['concept_tagging_of_url'].should eql(["Canada", "English language"])
        output.first['concept_tagging_relevance_of_url'].should eql([89.5153, 79.0912])
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:url => ["{{url}}"]})
        line.stations.first.worker.type.should eql("ConceptTaggingRobot")
      end
    end
  end
end