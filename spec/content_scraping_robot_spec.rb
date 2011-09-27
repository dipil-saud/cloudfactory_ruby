# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a content scraping robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "content_scraping_robot", :settings => {:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"}})
          end
        end
        run = CF::Run.create(line, "content_scraping_robot_run", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        output = run.final_output
        output.first['scraped_link_from_document'].should eql([""])
        output.first['scraped_text_from_document'].should eql([""])

        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"})
        line.stations.first.worker.type.should eql("ContentScrapingRobot")
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

        worker = CF::RobotWorker.create({:type => "content_scraping_robot", :settings => {:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "content_scraping_robot_run_1", [{"url"=> "http://www.sprout-technology.com"}])
        sleep 10
        output = run.final_output
        output.first['scraped_link_from_document'].should eql([""])
        output.first['scraped_text_from_document'].should eql([""])

        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["http://www.sprout-technology.com"], :query => "1st 2 links after Sprout products"})
        line.stations.first.worker.type.should eql("ContentScrapingRobot")
      end
    end
  end
end