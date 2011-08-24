module CF
  class Run
    require 'httparty'
    include Client

    # Title of the "run" object
    attr_accessor :title

    # File attribute to upload for Production Run
    attr_accessor :file
    
    # Input to be passed for Production Run
    attr_accessor :input

    # Line attribute with which run is associated
    attr_accessor :line
    
    # Contains Error Message if any
    attr_accessor :errors

    # ==Initializes a new Run
    # ===Usage Example:
    #
    #   run = CF::Run.new("line_title", "run name", file_path)
    #
    # ==OR
    # You can pass line object instead of passing line title:
    #   run = CF::Run.new(line_object, "run name", file_path)
    def initialize(line, title, input)
      if line.class == CF::Line || line.class == Hashie::Mash
        @line = line
        @line_title = line.title
      elsif line.class == String
        if line.split("/").count == 2
          @account = line.split("/").first
          @line_title = line.split("/").last
        elsif line.split("/").count == 1
          @line_title = line
        end
      end
      @title = title
      if File.exist?(input.to_s)
        @file = input
        @param_data = File.new(input, 'rb')
        @param_for_input = :file
        if line.class == String && line.split("/").count == 2
          resp = self.class.post("/lines/#{@account}/#{@line_title.downcase}/runs.json", {:data => {:run => {:title => @title}}, @param_for_input => @param_data})
        else
          resp = self.class.post("/lines/#{CF.account_name}/#{@line_title.downcase}/runs.json", {:data => {:run => {:title => @title}}, @param_for_input => @param_data})
        end
        if resp.code != 200
          self.errors = resp.error.message
        end
      else
        @input = input
        @param_data = input
        @param_for_input = :inputs
        options = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :data =>{:run => { :title => @title }, :inputs => @param_data}
          }
        }
        if line.class == String && line.split("/").count == 2
          run =  HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{@account}/#{@line_title.downcase}/runs.json",options)
        else
          run =  HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line_title.downcase}/runs.json",options)
        end
        if run.code != 200
          self.errors = run.parsed_response['error']['message']
        end
      end
    end

    # ==Creates a new Run
    # ===Usage Example:
    #
    #   run = CF::Run.new("line_title", "run name", file_path)
    #
    # ==OR
    # You can pass line object instead passing line title:
    #   run = CF::Run.new(line_object, "run name", file_path)
    def self.create(line, title, file)
      Run.new(line, title, file)
    end

    # ==Returns Final Output of production Run
    # ===Usage Example:
    #   run_object.final_output
    def final_output
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output.json")
      output = []
      if resp['output'].class == Array
        resp['output'].each do |o|
          output << o.to_hash
        end
      end
      return output
    end

    # ==Returns Final Output of production Run
    # ===Usage Example:
    #   CF::Run.final_output("run_title")
    def self.final_output(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output.json")
      output = []
      if resp['output'].class == Array
        resp['output'].each do |o|
          output << o.to_hash
        end
      end
      return output
    end
    
    # ==Returns Output of production Run for any specific Station and for given Run Title
    # ===Usage Example:
    #   CF::Run.output({:title => "run_title", :station => 2})
    # Will return output of second station
    def self.output(options={})
      station_no = options[:station]
      title = options[:title]
      resp = get("/runs/#{CF.account_name}/#{title.downcase}/output/#{station_no}.json")
      output = []
      if resp['output'].class == Array
        resp['output'].each do |o|
          output << o.to_hash
        end
      end
      return output
    end
    
    # ==Returns Output of Run object for any specific Station
    # ===Usage Example:
    #   run_object.output(:station => 2)
    # Will return output of second station
    def output(options={})
      station_no = options[:station]
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output/#{station_no}.json")
      output = []
      if resp['output'].class == Array
        resp['output'].each do |o|
          output << o.to_hash
        end
      end
      return output
    end
    
    # ==Searches Run for the given "run_title"
    # ===Usage Example:
    #   CF::Run.find("run_title")
    def self.find(title)
      resp = get("/runs/#{CF.account_name}/#{title.downcase}.json")
      if resp.code != 200
        resp.error = resp.error.message
        resp.merge!(:errors => "#{resp.error}")
        resp.delete(:error)
      end
      return resp
    end
    
    def self.progress(run_title)
      get("/runs/#{CF.account_name}/#{run_title}/progress.json")
    end
    
    def progress
      self.class.get("/runs/#{CF.account_name}/#{self.title}/progress.json")
    end
    
    def self.progress_details(run_title)
      resp = get("/runs/#{CF.account_name}/#{run_title}/details.json")
      return resp['progress_details']
    end
    
    def progress_details
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title}/details.json")
      return resp['progress_details']
    end
    
    def self.all(options={})
      page = options[:page].presence
      line_title = options[:line_title].presence
      
      if line_title.nil?
        if page.nil?
          resp = get("/runs/#{CF.account_name}.json")
        else
          resp = get("/runs/#{CF.account_name}.json", :page => page)
        end
      else
        if page.nil?
          resp = get("/lines/#{CF.account_name}/#{line_title}/list_runs.json")
        else
          resp = get("/lines/#{CF.account_name}/#{line_title}/list_runs.json", :page => page)
        end
      end
      self.errors == resp.errors.message if resp.code != 200
      if resp.code == 200
        new_resp = []
        if resp.runs.count > 0
          resp.runs.each do |r|
            new_resp << r.to_hash
          end
        end
        send_resp = {"runs" => new_resp, "total_pages" => resp.total_pages}
        return send_resp
      end
    end
    
    def self.resume(run_title)
      post("/runs/#{CF.account_name}/#{run_title}/resume.json")
    end
  end
end