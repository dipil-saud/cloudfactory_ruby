require 'spec_helper'

module CF
  describe CF::HumanWorker do
    context "create a worker" do
      it "the block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title, "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            @worker = CF::HumanWorker.new({:station => s, :number => 1, :reward => 20})
          end
        end
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.reward.should eql(20)
      end

      it "in block DSL way with invalid data and should set the error" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title, "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            @worker = CF::HumanWorker.new({:station => s})
          end
        end
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.errors.should eql("[\"Reward is not a number\", \"Reward can't be blank\"]")
      end

      it "in plain ruby way with invalid data and should set the error" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.new(title, "Digitization")
        input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new()
        line.stations.first.worker = worker

        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.errors.should eql("[\"Reward is not a number\", \"Reward can't be blank\"]")
      end

      it "should only display the attributes which are mentioned in to_s method" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        line = CF::Line.create(title, "Digitization") do
          CF::InputFormat.new({:line => self, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line => self, :type => "work"}) do |station|
            CF::HumanWorker.new({:station => station, :number => 1, :reward => 20})
          end
        end
        line.stations.first.worker.to_s.should eql("{:id => => #{line.stations.first.worker.id}, :number => 1, :reward => 20, :stat_badge => {\"approval_rating\"=>80, \"assignment_duration\"=>3600, \"abandonment_rate\"=>30, \"country\"=>nil},  :skill_badges => [nil], :errors => }")
      end
    end

    context "create a worker with skill_badge and skill_test" do
      it "the Block DSL way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
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
        line = CF::Line.create(title, "Digitization") do |l|
          CF::InputFormat.new({:line => l, :name => "image_url", :required => true, :valid_type => "url"})
          CF::Station.create({:line =>l, :type => "work"}) do |s|
            @worker = CF::HumanWorker.new({:station => s, :number => 1, :reward => 20, :skill_badge => badge})
          end
        end
        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.worker.skill_badges.first.should eql([{"title"=>"Football Fanatic", "description"=>"This qualification allows you to perform work at stations which have this badge.", "score"=>nil, "quality_rating"=>nil, "max_badges"=>3, "skill_test"=>{"score_after"=>"submit", "manual_scoring"=>false, "display_answers"=>false, "edit_answers"=>true, "retries"=>0, "pass_percentage"=>100, "test_units"=>[{"input"=>{"name"=>"Lionel Andres Messi", "country"=>"Argentina"}, "expected_output"=>[{"birthplace"=>"Rosario, Santa Fe, Argentina", "match_options"=>{"tolerance"=>"1", "ignore_case"=>"false"}, "position"=>"CF", "current-club"=>"Barcelona"}], "match_options"=>{"tolerance"=>0, "ignore_case"=>false}}]}}])
        line.stations.first.worker.stat_badge.should eql({"approval_rating"=>80, "assignment_duration"=>3600, "abandonment_rate"=>30, "country"=>nil})
      end

      it "in plain ruby way" do
        WebMock.allow_net_connect!
        title = "line_title#{Time.new.strftime('%Y%b%d-%H%M%S')}".downcase
        sleep 1
        skill_badge = 
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
        line = CF::Line.new(title, "Digitization")
        input_format = CF::InputFormat.new({:name => "image_url", :required => true, :valid_type => "url"})
        line.input_formats input_format

        station = CF::Station.new({:type => "work"})
        line.stations station

        worker = CF::HumanWorker.new({:number => 1, :reward => 20, :skill_badge => skill_badge})
        line.stations.first.worker = worker

        line.stations.first.type.should eql("WorkStation")
        line.stations.first.worker.number.should eql(1)
        line.stations.first.worker.reward.should eql(20)
        line.stations.first.worker.skill_badges.first.should eql([{"title"=>"Football Fanatic", "description"=>"This qualification allows you to perform work at stations which have this badge.", "score"=>nil, "quality_rating"=>nil, "max_badges"=>3, "skill_test"=>{"score_after"=>"submit", "manual_scoring"=>false, "display_answers"=>false, "edit_answers"=>true, "retries"=>0, "pass_percentage"=>100, "test_units"=>[{"input"=>{"name"=>"Lionel Andres Messi", "country"=>"Argentina"}, "expected_output"=>[{"birthplace"=>"Rosario, Santa Fe, Argentina", "match_options"=>{"tolerance"=>"1", "ignore_case"=>"false"}, "position"=>"CF", "current-club"=>"Barcelona"}], "match_options"=>{"tolerance"=>0, "ignore_case"=>false}}]}}])
        line.stations.first.worker.stat_badge.should eql({"approval_rating"=>80, "assignment_duration"=>3600, "abandonment_rate"=>30, "country"=>nil})
      end
    end
  end
end