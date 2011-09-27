# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create a mailer robot worker" do
      it "should create mailer robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        @template = "<html><body><h1>Hello {{to}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "to", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "mailer_robot", :settings => {:to => ["manish.das@sprout-technology.com"], :template => @template}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"to"=> "manish.das@sprout-technology.com"}])
        sleep 20
        output = run.final_output
        output.first['recipients_of_to'].should eql(["manish.das@sprout-technology.com"])
        output.first['sent_message_for_to'].should eql("<html><body><h1>Hello manish.das@sprout-technology.com Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:to => ["manish.das@sprout-technology.com"], :template => @template})
        line.stations.first.worker.type.should eql("MailerRobot")
      end

      it "should create mailer robot worker for first station in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        @template = "<html><body><h1>Hello {{to}} Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>"
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "to", :required => "true"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker =  CF::RobotWorker.create({:type => "mailer_robot", :settings => {:to => ["manish.das@sprout-technology.com"], :template => @template}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "run-#{title}", [{"to"=> "manish.das@sprout-technology.com"}])
        sleep 20
        output = run.final_output
        output.first['recipients_of_to'].should eql(["manish.das@sprout-technology.com"])
        output.first['sent_message_for_to'].should eql("<html><body><h1>Hello manish.das@sprout-technology.com Welcome to CLoudfactory!!!!</h1><p>Thanks for using!!!!</p></body></html>")
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.01)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:to => ["manish.das@sprout-technology.com"], :template => @template})
        line.stations.first.worker.type.should eql("MailerRobot")\
      end
    end
  end
end