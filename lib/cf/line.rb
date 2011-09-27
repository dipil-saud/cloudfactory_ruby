module CF
  class Line
    require 'httparty'
    include Client

    # Title of the Line
    attr_accessor :title

    # Department Name for Line
    attr_accessor :department_name

    # Public is a boolean attribute which when set to true becomes public & vice-versa
    #
    # Public attribute is optional, by default it's true
    attr_accessor :public

    # Description attribute describes about the line
    #
    # Description attribute is optional
    attr_accessor :description

    # stations contained within line object
    attr_accessor :stations

    # input_formats contained within line object
    attr_accessor :input_formats
    
    # Contains Error Messages
    attr_accessor :errors
    
    # output_formats of the final output for a line
    attr_accessor :output_formats

    # ==Initializes a new line
    # ==Usage of line.new("line_name")
    #
    #     line = Line.new("line_name", "Survey")
    def initialize(title, department_name, options={})
      @input_formats =[]
      @stations =[]
      @title = title
      @department_name = department_name
      @public = options[:public].nil? ? true : options[:public]
      @description = options[:description]
      resp = self.class.post("/lines/#{CF.account_name}.json", {:line => {:title => title, :department_name => department_name, :public => @public, :description => @description}})
      self.errors = resp['error']['message'] if resp['code'] != 200
      return resp
    end

    # ==Adds station in a line
    # ===Usage Example:
    #   line = CF::Line.new("line_name", "Department_name")
    #   station = CF::Station.new({:type => "Work"})
    #   line.stations station
    #
    # * returns
    # line.stations as an array of stations
    def stations stations = nil
      if stations
        type = stations.type
        @batch_size = stations.batch_size
        @station_input_formats = stations.station_input_formats
        if type == "Improve" && self.stations.size < 1
          raise ImproveStationNotAllowed.new("You cannot add Improve Station as a first station of a line")
        else
          if type == "Tournament"
            @jury_worker = stations.jury_worker
            @auto_judge = stations.auto_judge
            @acceptance_ratio = stations.acceptance_ratio
            if @batch_size.nil?
              request_tournament = 
              {
                :body => 
                {
                  :api_key => CF.api_key,
                  :station => {:type => type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats}
                }
              }
            else
              if @acceptance_ratio.nil?
                request_tournament = 
                {
                  :body => 
                  {
                    :api_key => CF.api_key,
                    :station => {:type => type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats, :batch_size => @batch_size}
                  }
                }
              else
                request_tournament = 
                {
                  :body => 
                  {
                    :api_key => CF.api_key,
                    :station => {:type => type, :jury_worker => @jury_worker, :auto_judge => @auto_judge, :input_formats => @station_input_formats, :batch_size => @batch_size, :acceptance_ratio => @acceptance_ratio}
                  }
                }
              end
            end
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/stations.json",request_tournament)
          else
            if @batch_size.nil?
              request_general = 
              {
                :body => 
                {
                  :api_key => CF.api_key,
                  :station => {:type => type, :input_formats => @station_input_formats}
                }
              }
            else
              request_general = 
              {
                :body => 
                {
                  :api_key => CF.api_key,
                  :station => {:type => type, :input_formats => @station_input_formats, :batch_size => @batch_size}
                }
              }
            end
            resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/stations.json",request_general)
          end
          station = CF::Station.new()
          resp.to_hash.each_pair do |k,v|
            station.send("#{k}=",v) if station.respond_to?(k)
          end
          station.batch_size = @batch_size
          station.line = self
          station.line_title = self.title
          station.errors = resp.parsed_response['error']['message'] if resp.response.code != "200"
          @stations << station
        end
      else
        @stations
      end
    end

    def stations=(stations) # :nodoc:
      @stations << stations
    end

    # ==Initializes a new line
    # ===Usage Example:
    #
    # ===creating Line within block using variable
    #   Line.create("line_name", "Department_name") do |line|
    #     CF::InputFormat.new({:line => line, :label => "image_url", :required => true, :valid_type => "url"})
    #     CF::Station.new({:line => line, :type => "Work"})
    #   end
    #
    # ==OR
    # ===creating without variable
    #   CF::Line.create("line_name", "Department_name") do
    #     CF::InputFormat.new({:line => self, :label => "image_url", :required => true, :valid_type => "url"})
    #     CF::Station.new({:line => self, :type => "Work"})
    #   end
    def self.create(title, department_name, options={}, &block)
      line = Line.new(title,department_name,options={})
      @public = options[:public]
      @description = options[:description]
      if block.arity >= 1
        block.call(line)
      else
        line.instance_eval &block
      end
      line
    end

    # ==Adds input format in a line
    # ===Usage Example:
    #   line = Line.new("line name", "Survey")
    #
    #   input_format = CF::InputFormat.new({:label => "image_url", :required => true, :valid_type => "url"})
    #   line.input_formats input_format
    # * returns
    # line.input_formats as an array of input_formats
    def input_formats input_formats_value = nil
      if input_formats_value
        name = input_formats_value.name
        required = input_formats_value.required
        valid_type = input_formats_value.valid_type.nil? ? nil : input_formats_value.valid_type
        if valid_type
          @resp = CF::InputFormat.post("/lines/#{CF.account_name}/#{self.title.downcase}/input_formats.json", :input_format => {:name => name, :required => required, :valid_type => valid_type})
        elsif valid_type.nil?
          @resp = CF::InputFormat.post("/lines/#{CF.account_name}/#{self.title.downcase}/input_formats.json", :input_format => {:name => name, :required => required})
        end
        input_format = CF::InputFormat.new()
        @resp.each_pair do |k,v|
          input_format.send("#{k}=",v) if input_format.respond_to?(k)
        end
        input_format.errors = @resp['error']['message'] if @resp['code'] != 200
        @input_formats << input_format
      else
        @input_formats
      end
      
    end
    
    def input_formats=(input_formats_value) # :nodoc:
      @input_formats << input_formats_value
    end

    # ==Specifies output format for a line
    # ===Usage Example:
    #   output_format = CF::OutputFormat.new({:station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
    #   line.output_formats output_format
    def output_formats output_format = nil
      if output_format
        settings = output_format.settings
        request = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :output_formats => settings
          }
        }
        resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{self.title.downcase}/output_format.json",request)
        output_format.errors = resp.parsed_response['error']['message'] if resp.code != 200
        self.output_formats = output_format
      else
        @output_formats
      end
    end
    
    def output_formats=(output_format) # :nodoc:
      @output_formats = output_format
    end
    # ==Returns the content of a line by making an Api call
    # ===Usage Example:
    #   CF::Line.info(line)
    # ==OR
    #   CF::Line.info("line_title")
    def self.info(line)
      if line.class == CF::Line
        resp = get("/lines/#{CF.account_name}/#{line.title.downcase}.json")
      else
        resp = get("/lines/#{CF.account_name}/#{line.downcase}.json")
      end
      @errors = resp['error']['message'] if resp['code'] != 200
      return resp
    end

    # ==Finds a line
    # ===Usage Example:
    #   CF::Line.find(line)
    # ==OR
    #   CF::Line.find("line_title")
    def self.find(line)
      if line.class == CF::Line
        resp = get("/lines/#{CF.account_name}/#{line.title.downcase}.json")
      elsif line.class == String
        if line.split("/").count == 2
          account = line.split("/").first
          title = line.split("/").last
          resp = get("/lines/#{account}/#{title.downcase}.json")
        elsif line.split("/").count == 1
          resp = get("/lines/#{CF.account_name}/#{line.downcase}.json")
        end
      end
      @errors = resp['error']['message'] if resp['code'] != 200
      return resp
    end
    
    # ==Returns all the lines of an account
    # ===Syntax for all method is
    #   CF::Line.all
    # OR
    #   CF:Line.all(:page => 1)
    def self.all(options={})
      page = options[:page].presence
      if page
        resp = get("/lines/#{CF.account_name}.json", :page => page)
      else
        resp = get("/lines/#{CF.account_name}.json")
      end
      @errors = resp['error']['message'] if resp['code'] != 200
      # new_resp = []
      #      if resp['lines']
      #        if resp['lines'].count > 0
      #          resp['lines'].each do |l|
      #            new_resp << l.to_hash
      #          end
      #        end
      #      end
      #      send_resp = {"lines" => new_resp, "total_pages" => resp.total_pages, "total_lines" => resp.total_lines}
      return resp
    end
    
    # ==Returns all the stations of a line
    # ===Usage Example:
    #   CF::Line.get_stations
    def get_stations
      CF::Station.get("/lines/#{ACCOUNT_NAME}/#{self.title.downcase}/stations.json")
    end
    # ==Return all the public lines
    # ===Usage Example:
    #   CF::Line.public_lines
    def self.public_lines(options={})
      if options[:page]=="all"
        resp = get("/public_lines.json", :page => "all")
      else
        resp = get("/public_lines.json")
      end
      return resp['lines']
    end

    # ==Updates a line
    # ===Syntax for update method is
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.update({:title => "New Title"})
    # * This changes the title of the "line" object from "Digitize Card" to "New Title"
    def update(options={}) # :nodoc:
      old_title = self.title
      @title = options[:title]
      @department_name = options[:department_name]
      @public = options[:public]
      @description = options[:description]
      self.class.put("/lines/#{CF.account_name}/#{old_title.downcase}.json", :line => {:title => @title, :department_name => @department_name, :public => @public, :description => @description})
    end

    # ==Deletes a line
    # ===Usage Example:
    #   line = CF::Line.new("Digitize Card", "Survey")
    #   line.destroy
    def destroy(options={})
      force = options[:force]
      if !force.nil?
        resp = self.class.delete("/lines/#{CF.account_name}/#{self.title.downcase}.json", :forced => force)
      else
        resp = self.class.delete("/lines/#{CF.account_name}/#{self.title.downcase}.json")
      end
      self.errors = resp['error']['message'] if resp['code'] != 200
      return resp
    end
    
    # ==Deletes a line by passing it's title
    # ===Usage Example:
    #   line = CF::Line.new("line_title", "Survey")
    #   CF::Line.destroy("line_title")
    def self.destroy(title, options={})
      forced = options[:forced]
      if forced
        resp = delete("/lines/#{CF.account_name}/#{title.downcase}.json", {:forced => forced})
      else
        resp = delete("/lines/#{CF.account_name}/#{title.downcase}.json")
      end
      @errors = resp['error']['message'] if resp['code'] != 200
      return resp
    end
    
    # ==Return all the associated elements of a line
    # ===Usage Example:
    #   line = CF::Line.inspect("line_title")
    def self.inspect(line_title)
      resp = get("/lines/#{CF.account_name}/#{line_title.downcase}/inspect.json")
      @errors = resp['error']['message'] if resp['code'] != 200
      # if resp['code'] == 200
      #         send_resp = resp.to_hash
      #         # @line_input_formats = []
      #         #        resp.input_formats.each do |l_i|
      #         #          @line_input_formats << l_i.to_hash
      #         #        end
      #         #        send_resp.delete("input_formats")
      #         #        send_resp.merge!("input_formats" => @line_input_formats)
      #         # @stations = []
      #       
      #         # resp.stations.each do |s|
      #         #           @station_input_formats = []
      #         #           s.input_formats.each do |i|
      #         #             @station_input_formats << i.to_hash
      #         #           end
      #         #           @station_form_fields = []
      #         #           @temp_station = s.to_hash
      #         #           if !s.form_fields.nil?
      #         #             s.form_fields.each do |f|
      #         #               @station_form_fields << f.to_hash
      #         #             end
      #         #             @temp_station.delete("form_fields")
      #         #             @temp_station.merge!("form_fields" => @station_form_fields)
      #         #           end
      #         #           @temp_station.delete("input_formats")
      #         #           @temp_station.merge!("input_formats" => @station_input_formats)
      #         #           @stations << @temp_station
      #         #         end
      #               # 
      #               # send_resp.delete("stations")
      #               # send_resp.merge!("stations" => @stations)
      #         send_resp
      #       else
      return resp
      # end
    end
  end
end