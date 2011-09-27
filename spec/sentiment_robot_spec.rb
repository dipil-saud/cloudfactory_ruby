# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a sentiment robot worker" do
      it "should create content_scraping_robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :settings => {:document => ["{{url}}"], :sanitize => true}, :type => "sentiment_robot"})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.thehappyguy.com/happiness-self-help-book.html"}])
        sleep 10
        output = run.final_output
        output.first['sentiment_of_url'].should eql("positive")
        output.first['sentiment_relevance_of_url'].should eql(25.7649)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["{{url}}"], :sanitize => true})
        line.stations.first.worker.type.should eql("SentimentRobot")
      end

      it "should create content_scraping_robot worker for first station in plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker =  CF::RobotWorker.new({:settings => {:document => ["{{url}}"], :sanitize => true}, :type => "sentiment_robot"})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://www.thehappyguy.com/happiness-self-help-book.html"}])
        sleep 10
        output = run.final_output
        output.first['sentiment_of_url'].should eql("positive")
        output.first['sentiment_relevance_of_url'].should eql(25.7649)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["{{url}}"], :sanitize => true})
        line.stations.first.worker.type.should eql("SentimentRobot")
      end
    end
  end
end