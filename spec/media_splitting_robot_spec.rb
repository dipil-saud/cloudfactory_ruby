# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a media splitting robot worker" do
      it "should create media splitting robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "media_splitting_robot", :settings => {:url => ["{{url}}"], :split_duration => "2", :overlapping_time => "1"}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        sleep 10
        output = run.final_output
        converted_url_1= output.first['splits_of_url'].first
        converted_url_2= output.first['splits_of_url'].last
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_1}").should eql(true)
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_2}").should eql(true)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:url => ["{{url}}"], :split_duration => "2", :overlapping_time => "1"})
        line.stations.first.worker.type.should eql("MediaSplittingRobot")
      end

      it "should create media splitting robot worker for first station in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::RobotWorker.create({:type => "media_splitting_robot", :settings => {:url => ["{{url}}"], :split_duration => "2", :overlapping_time => "1"}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "run-#{title}", [{"url"=> "http://media-robot.s3.amazonaws.com/media_robot/media/upload/8/ten.mov"}])
        sleep 10
        output = run.final_output
        converted_url_1= output.first['splits_of_url'].first
        converted_url_2= output.first['splits_of_url'].last
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_1}").should eql(true)
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url_2}").should eql(true)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:url => ["{{url}}"], :split_duration => "2", :overlapping_time => "1"})
        line.stations.first.worker.type.should eql("MediaSplittingRobot")
      end
    end
  end
end