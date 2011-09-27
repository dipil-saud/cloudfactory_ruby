# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create an image processing robot worker" do
      it "should create image processing robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "url", :valid_type => "url", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "image_processing_robot", :settings => {:image => ["{{url}}"], :sharpen => {:radius => "10"}}})
          end
        end
        run = CF::Run.create(line, "image_processing_robot_run", [{"url"=> "http://wwwdelivery.superstock.com/WI/223/1527/PreviewComp/SuperStock_1527R-020214.jpg"}])
        sleep 10
        output = run.final_output
        converted_url = output.first['processed_image_of_url']
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:image => ["{{url}}"], :sharpen => {:radius => "10"}})
        line.stations.first.worker.type.should eql("ImageProcessingRobot")
      end

      it "should create image processing robot worker for first station in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::RobotWorker.create({:type => "image_processing_robot", :settings => {:image => ["{{url}}"], :sharpen => {:radius => "10"}}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "image_processing_robot_run_1", [{"url"=> "http://wwwdelivery.superstock.com/WI/223/1527/PreviewComp/SuperStock_1527R-020214.jpg"}])
        sleep 10
        output = run.final_output
        converted_url = output.first['processed_image_of_url']
        File.exist?("/Users/manish/apps/cloudfactory/public#{converted_url}").should eql(true)
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:image => ["{{url}}"], :sharpen => {:radius => "10"}})
        line.stations.first.worker.type.should eql("ImageProcessingRobot")
      end
    end
  end
end