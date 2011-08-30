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
    
    # ==Adds units to an existing production Run
    # ===Usage Example:
    #   units = CF::Run.add_units({:run_title => "title", :file => "path_of_file"})
    def self.add_units(options={})
      units = options[:units].nil? ? nil : options[:units]
      run_title = options[:run_title].presence
      file = options[:file].presence
      if units
        request = 
        {
          :body => 
          {
            :api_key => CF.api_key,
            :data => units
          }
        }
        resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/runs/#{CF.account_name}/#{run_title.downcase}/units.json",request)
        @errors = resp['error']['message'] if resp.code != 200
        return resp.parsed_response
      elsif file
        if File.exist?(file.to_s)
          file_upload = File.new(file, 'rb')
          resp = post("/runs/#{CF.account_name}/#{run_title.downcase}/units.json", {:file => file_upload})
          @errors = resp.error.message if resp.code != 200
          return resp.to_hash
        end
      end
    end
    # ==Returns Final Output of production Run
    # ===Usage Example:
    #   run_object.final_output
    def final_output
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title.downcase}/output.json")
      self.errors = resp.error.message if resp.code != 200
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
      @errors = resp.error.message if resp.code != 200
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
      @errors = resp.error.message if resp.code != 200
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
      self.errors = resp.error.message if resp.code != 200
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
        @errors = resp.error.message
        resp.error = resp.error.message
        resp.merge!(:errors => "#{resp.error}")
        resp.delete(:error)
      end
      return resp
    end
    
    # ==Returns progress of the production run
    # ===Usage Example:
    #   progress = CF::Run.progress("run_title")
    def self.progress(run_title)
      get("/runs/#{CF.account_name}/#{run_title}/progress.json")
    end
    
    def progress # :nodoc:
      self.class.get("/runs/#{CF.account_name}/#{self.title}/progress.json")
    end
    
    # ==Returns progress details of the production run
    # ===Usage Example:
    #   progress = CF::Run.progress_details("run_title")
    def self.progress_details(run_title)
      resp = get("/runs/#{CF.account_name}/#{run_title}/details.json")
      return resp['progress_details']
    end
    
    def progress_details # :nodoc:
      resp = self.class.get("/runs/#{CF.account_name}/#{self.title}/details.json")
      return resp['progress_details']
    end
    
    # ==Returns all runs of a line
    # ===Usage Example:
    #   progress = CF::Run.all({:line_title => "line_title", :page => 1)
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
      
      if resp.code != 200
        send_resp = {"error" => resp.error.message}
        return send_resp
      end

      new_resp = []
      if resp.code == 200
        if resp.runs
          if resp.runs.count > 0
            resp.runs.each do |r|
              new_resp << r.to_hash
            end
          end
        end
        send_resp = {"runs" => new_resp, "total_pages" => resp.total_pages, "total_runs" => resp.total_runs}
        return send_resp
      end
    end
    
    # ==Resumes the paused production run
    # ===Usage Example:
    #   resume_run = CF::Run.resume("run_title")
    def self.resume(run_title)
      resp = post("/runs/#{CF.account_name}/#{run_title}/resume.json")
      @errors = resp.error.message if resp.code != 200
      return resp
    end
  
    # ==Deletes the production run
    # ===Usage Example:
    #   delete_run = CF::Run.destroy("run_title")
    def self.destroy(run_title)
      resp = delete("/runs/#{CF.account_name}/#{run_title}.json")
      @errors = resp.error.message if resp.code != 200
      return resp
    end
  end
end