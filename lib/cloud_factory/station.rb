module CloudFactory
  class Station
    include Client

    # type of the station, e.g. station = Station.new(line, {:type => "Work"})
    attr_accessor :type

    # line attribute is parent attribute for station & is required for making Api call
    attr_accessor :line_id

    # ID of the station
    attr_accessor :id

    # ==Initializes a new station
    # ===Usage Example
    #   line = CloudFactory::Line.new("Digitize", "Survey")
    #   station = CloudFactory::Station.new({:line => line, :type => "Work"})
    def initialize(options={})
      @input_headers =[]
      @line_id = options[:line].nil? ? nil : options[:line].id
      @type = options[:type].nil? ? nil : options[:type].camelize
      if !@line_id.nil?
        resp = self.class.post("/lines/#{@line_id}/stations.json", :station => {:type => @type})
        @id = resp.id
        line = options[:line]
        line.stations = self
      end
    end

    # ==Initializes a new station within block
    # ===Usage Example
    # ===Creating station using block variable
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    # ===OR creating without variable within block
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do
    #     CloudFactory::InputHeader.new({:line => self, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => self, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => self, :type => "work") do
    #       CloudFactory::HumanWorker.new({:station => self, :number => 1, :reward => 20)
    #       CloudFactory::Form.create({:station => self, :title => "Enter text from a business card image", :description => "Describe"}) do
    #         CloudFactory::FormField.new({:instruction => self, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => self, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => self, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    def self.create(options, &block)
      station = Station.new(options)
      if block.arity >= 1
        block.call(station)
      else
        station.instance_eval &block
      end
      station
    end

    # ==Creates new instruction for station object
    # ===Usage of worker method for "station" object
    #   line = CloudFactory::Line.new("line name", "Survey")
    #   station = CloudFactory::Station.new({:type => "work"})
    #   line.stations station
    #   human_worker = CloudFactory::HumanWorker.new({:number => 1, :reawrd => 20})
    #   line.stations.first.worker human_worker
    def worker worker_instance = nil
      if worker_instance
        @worker_instance = worker_instance
      else
        @worker_instance
      end
    end

    def worker=(worker_instance) # :nodoc:
      worker_type = worker_instance.class.to_s.split("::").last
      case worker_type
      when "HumanWorker"
        number = worker_instance.number
        reward = worker_instance.reward
        resp = CloudFactory::HumanWorker.post("/stations/#{self.id}/workers.json", :worker => {:number => number, :reward => reward, :type => "HumanWorker"})
        worker = CloudFactory::HumanWorker.new({})
        resp.to_hash.each_pair do |k,v|
          worker.send("#{k}=",v) if worker.respond_to?(k)
        end
        @worker_instance = worker

      else
        number = 1
        reward = 0
        resp = worker_instance.class.post("/stations/#{self.id}/workers.json", :body => {:worker => {:number => 1, :reward => 0, :type => type}})
        worker = worker_instance.class.new({})
        resp.to_hash.each_pair do |k,v|
          worker.send("#{k}=",v) if worker.respond_to?(k)
        end
        @worker_instance = worker
      end
    end

    # ==Creates new instruction for station object
    # ===Usage of Instruction method for "station" object
    #   line = CloudFactory::Line.new("line name", "Survey")
    #   station = CloudFactory::Station.new({:type => "work"})
    #   line.stations station
    #   standard_instruction = CloudFactory::Form.new({:title => "title", :description => "description"})
    #   line.stations.first.instruction instruction
    def instruction instruction_instance = nil
      if instruction_instance
        @instruction_instance = instruction_instance
      else
        @instruction_instance
      end
    end
    def instruction=(instruction_instance) # :nodoc:
      title = instruction_instance.title
      description = instruction_instance.description
      resp = CloudFactory::Form.post("/stations/#{self.id}/instruction.json", :instruction => {:title => title, :description => description, :_type => "Form"})
      form = CloudFactory::Form.new({})
      resp.to_hash.each_pair do |k,v|
        form.send("#{k}=",v) if form.respond_to?(k)
      end
      form.station = self
      @instruction_instance = form
    end

    # ==Usage of line.input_headers(input_header)
    #   line = CloudFactory::Line.new("line name", "Survey")
    #   station = CloudFactory::Station.new({:type => "work"})
    #   line.stations station
    #   input_header = CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #   line.stations.first.input_headers input_header
    # * returns
    # line.stationss.first.input_headers as an array of input_headers
    def input_headers input_headers_value = nil
      if input_headers_value
        label = input_headers_value.label
        field_type = input_headers_value.field_type
        value = input_headers_value.value
        required = input_headers_value.required
        validation_format = input_headers_value.validation_format
        resp = CloudFactory::InputHeader.post("/lines/#{self.line_id}/input_headers.json", :input_header => {:label => label, :field_type => field_type, :value => value, :required => required, :validation_format => validation_format})

        input_header = CloudFactory::InputHeader.new()
        resp.to_hash.each_pair do |k,v|
          input_header.send("#{k}=",v) if input_header.respond_to?(k)
        end
        @input_headers << input_header
      else
        @input_headers
      end
    end
    def input_headers=(input_headers_value) # :nodoc:
      @input_headers << input_headers_value
    end
    # ==Updates Standard Instruction of a station
    # ===Usage example
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #     end
    #   end
    #   line.stations[0].update_instruction({:title => "Enter phone number from a business card image", :description => "Call"})
    def update_instruction(options={})
      @title       = options[:title]
      @description = options[:description]
      self.class.put("/stations/#{self.id}/instruction.json", :instruction => {:title => @title, :description => @description, :type => "Form"})
    end

    # ==Returns a particular station of a line
    # ===Usage example for get_station() method
    #   line = CloudFactory::Line.create("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new({:line => line, :type => "Work"})
    #   line.stations station
    #
    #   got_station = line.stations[0].get
    # returns the station object
    def get
      self.class.get("/lines/#{self.line_id}/stations/#{self.id}.json")
    end

    # ==Returns information of instruction
    # ===Usage example
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   @got_instruction = line.stations[0].get_instruction
    def get_instruction
      self.class.get("/stations/#{self.id}/instruction.json")
    end

    # ==Returns all the stations associated with a particular line
    # ===Usage example for station.all method is
    #   line = CloudFactory::Line.create("Digitize Card","Digitization") do |l|
    #     CloudFactory::InputHeader.new({:line => l, :label => "Company", :field_type => "text_data", :value => "Google", :required => true, :validation_format => "general"})
    #     CloudFactory::InputHeader.new({:line => l, :label => "Website", :field_type => "text_data", :value => "www.google.com", :required => true, :validation_format => "url"})
    #     CloudFactory::Station.create({:line => l, :type => "work") do |s|
    #       CloudFactory::HumanWorker.new({:station => s, :number => 1, :reward => 20)
    #       CloudFactory::Form.create({:station => s, :title => "Enter text from a business card image", :description => "Describe"}) do |i|
    #         CloudFactory::FormField.new({:instruction => i, :label => "First Name", :field_type => "SA", :required => "true"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Middle Name", :field_type => "SA"})
    #         CloudFactory::FormField.new({:instruction => i, :label => "Last Name", :field_type => "SA", :required => "true"})
    #       end
    #     end
    #   end
    #
    #   CloudFactory::Station.all(line)
    # returns all stations
    def self.all(line)
      get("/lines/#{line.id}/stations.json")
    end

    # ==Deletes a station
    # * We need to pass line object with which desired station associated with as an argument to delete a station
    # ===Usage example for delete method
    #   line = CloudFactory::Line.new("Digitize Card", "4dc8ad6572f8be0600000001")
    #   station = CloudFactory::Station.new({:line =. line, :type => "Work"})
    #   line.stations station
    #
    #   station.delete
    def delete
      self.class.delete("/lines/#{self.line_id}/stations/#{self.id}.json")
    end
  end
end