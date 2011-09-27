# encoding: utf-8 
require 'spec_helper'

module CF
  describe CF::RobotWorker do
    context "create an entity extraction robot worker" do
      it "should create entity extraction robot worker for first station in Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title,"Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "text", :required => "true"})
          CF::Station.create({:line => l, :type => "work"}) do |s|
            CF::RobotWorker.create({:station => s, :type => "entity_extraction_robot", :settings => {:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]}})
          end
        end
        run = CF::Run.create(line, "run-#{title}", [{"text"=> "Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"}])
        sleep 10
        output = run.final_output
        output.first['entity_counts_of_document'].should eql(["2", "2", "1", "2", "1", "1"])
        output.first['entity_names_of_document'].should eql(["Ludwig Von Beethoven", "Franz Kafka", "George Orwell", "countries", "Mozart", "Japan"])
        output.first['entity_relevances_of_document'].should eql([94.98649999999999, 76.0806, 48.079100000000004, 30.461899999999996, 28.9416, 21.1997])
        output.first['entity_types_of_document'].should eql(["Person", "Person", "Person", "Country", "Person", "Country"])
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]})
      end

      it "should create entity extraction robot worker for first station in a plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title,"Digitization")
        input_format = CF::InputFormat.new({:name => "text", :required => "true"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::RobotWorker.create({:type => "entity_extraction_robot", :settings => {:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]}})
        line.stations.first.worker = worker

        run = CF::Run.create(line, "run-#{title}", [{"text"=> "Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"}])
        sleep 10
        output = run.final_output
        output.first['entity_counts_of_document'].should eql(["2", "2", "1", "2", "1", "1"])
        output.first['entity_names_of_document'].should eql(["Ludwig Von Beethoven", "Franz Kafka", "George Orwell", "countries", "Mozart", "Japan"])
        output.first['entity_relevances_of_document'].should eql([94.98649999999999, 76.0806, 48.079100000000004, 30.461899999999996, 28.9416, 21.1997])
        output.first['entity_types_of_document'].should eql(["Person", "Person", "Person", "Country", "Person", "Country"])
        line.stations.first.worker.class.should eql(CF::RobotWorker)
        line.stations.first.worker.reward.should eql(0.5)
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.settings.should eql({:document => ["Franz Kafka and George Orwell are authors. Ludwig Von Beethoven and Mozart are musicians. China and Japan are countries"]})
      end
    end
  end
end