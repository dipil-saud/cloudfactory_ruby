require 'thor/group'

module Cf # :nodoc: all
  class Production < Thor # :nodoc: all
    include Cf::Config
    
    no_tasks do
      def extract_name(file_path)
        Pathname.new(file_path).basename.to_s
      end
    end
    
    desc "production start <run-title>", "creates a production run with input data file at input/<run-title>.csv"
    method_option :input_data, :type => :string, :aliases => "-i", :desc => "the name of the input data file"
    method_option :live, :type => :boolean, :default => false, :desc => "specifies sandbox or live mode"
    method_option :line, :type => :string, :aliases => "-l", :desc => "public line to use to do the production run. the format should be <account_name>/<line-title> e.g. millisami/brandiator"
    def start(title=nil)      
      line_destination  = Dir.pwd
      yaml_source       = "#{line_destination}/line.yml"

      set_target_uri(options[:live])
      set_api_key
      CF.account_name = CF::Account.info.name
      
      if options[:line].present?
        line = CF::Line.find(options[:line])
        line = Hashie::Mash.new(line)
        if line.error.blank?
          line_title = options[:line]
        else
          say("#{line.error.message}", :red) and return
        end
      elsif File.exist?("#{yaml_source}")
        line_yaml_dump = YAML::load(File.read(yaml_source).strip)
        line_title = line_yaml_dump['title'].parameterize        
        line = CF::Line.find(line_title)
        line = Hashie::Mash.new(line)
        say("#{line.error.message}", :red) and return if line.error.present? 
      else
        say("Looks like you're not in the Line directory or did not provide the line title to use the line", :red) and return
      end

      if title.nil?
        if line_title =~  /\w\/\w/
          run_title       = "#{line_title.split("/").last}-#{Time.new.strftime('%y%b%e-%H%M%S')}".downcase
        else
          run_title       = "#{line_title}-#{Time.new.strftime('%y%b%e-%H%M%S')}".downcase
        end
      else
        run_title       = "#{title.parameterize}-#{Time.new.strftime('%y%b%e-%H%M%S')}".downcase
      end

      input_data = options[:input_data].presence
      
      if input_data =~ /^\// #checking absolute input data path
        input_data_file = input_data
      else
        if Dir.exist?("#{line_destination}/input")
          input_data_dir = "#{line_destination}/input"
          input_files = Dir["#{input_data_dir}/*.csv"]
          file_count = input_files.size
          case file_count
          when 0
            say("No input data file present inside the input folder", :red) and return
          when 1
            input_data_file = "#{Dir.pwd}/input/#{extract_name(input_files.first)}"
          else
            # Let the user choose the file
            chosen_file = nil
            choose do |menu|
              menu.header = "Input data files"
              menu.prompt = "Please choose which file to be used as input data: "

              input_files.each do |item|
                menu.choice(extract_name(item)) do
                  chosen_file = extract_name(item)
                  say("Using the file #{chosen_file} as input data")
                end
              end
            end
            input_data_file = "#{Dir.pwd}/input/#{chosen_file}"
          end
        else
          unless File.exist?(input_data)
            say("The input data file named #{input_data} doesn't exist", :red) and return
          end
          input_data_file = "#{Dir.pwd}/#{input_data}"
        end
      end
      
      unless File.exist?(input_data_file)
        say("The input data file named #{input_data} is missing", :red) and return
      end
      
      say "Creating a production run with title #{run_title}", :green
      run = CF::Run.create(line_title, run_title, input_data_file)
      if run.errors.blank?
        display_success_run(run)
      else
        say("Error: #{run.errors}", :red)
      end
    end

    no_tasks do
      def display_success_run(run)
        say("Run created successfully.", :green)
        say("View your production at:\n\thttp://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/runs/#{CF.account_name}/#{run.title}/workerpool_preview\n", :green)
      end
    end
    
    desc "production list", "list the production runs"
    method_option :line, :type => :string, :aliases => "-l", :desc => "the title of the line, if the line title is not given, it will show all the production runs under your account"
    method_option :page, :type => :numeric, :aliases => "-p", :desc => "page number"
    method_option :all, :type => :boolean, :default => false, :aliases => '-a', :desc => "list all the production runs"
    def list
      set_target_uri(false)
      set_api_key
      CF.account_name = CF::Account.info.name
      param = {}
      current_page = 1

      if options['line'].present?
        line_title = options['line'].parameterize
        param.merge!({:line_title => line_title})

        if options['all']
          param.merge!({:page => "all"})
          current_page = 1
        end
        
        if page = options['page'].presence
          param.merge!({:page => page})
          current_page = page
        end

      else
        if options['all']
          param = {:page => "all"}
          current_page = 1
        end

        if page = options['page'].presence
          param.merge!({:page => page})
          current_page = page
        end
      end

      resp_runs = CF::Run.all(param)
      
      if resp_runs.has_key?('error')
        say("#{resp_runs['error']}", :red) and exit(1)
      end
      
      if resp_runs.has_key?("runs") && resp_runs['runs'].blank?
        say("\nRun list is empty.\n", :yellow) and return
      end
      
      if resp_runs['total_pages']
        say("\nShowing page #{current_page} of #{resp_runs['total_pages']} (Total runs: #{resp_runs['total_runs']})")
      end
      runs = resp_runs['runs'].presence
      runs.sort! {|a, b| a['title'] <=> b['title'] }
      runs_table = table do |t|
        t.headings = ["Run Title", 'URL', 'Status']
        runs.each do |run|
          run = Hashie::Mash.new(run)
          t << [run.title, "http://#{CF.account_name}.cloudfactory.com/runs/#{CF.account_name}/#{run.title}", run.status]
        end
      end
      say("\n")
      if runs_table.rows.present?
        say(runs_table)
      else
        say("No production run for line #{line_title}", :yellow)
      end
    end
    
    desc "production resume", "resume a paused production run"
    method_option :run_title, :type => :string, :required => true, :aliases => "-r", :desc => "the title of the run to resume"
    def resume
      set_target_uri(false)
      set_api_key
      CF.account_name = CF::Account.info.name
      result = CF::Run.resume(options['run_title'].parameterize)

      if result.error.present?
        say("Error: #{result.error.message}", :red) and exit(1)
      end

      # if result.status == "resumed"
      say("Run with title \"#{result.title}\" is resumed!", :green)
      # end
    end   
    
    desc "production add_units", "add units to already existing production run"
    method_option :run_title, :type => :string, :required => true, :aliases => "-t", :desc => "the title of the run to resume"
    method_option :input_data, :type => :string, :required => true, :aliases => "-i", :desc => "the path of the input data file"
    
    def add_units
      set_target_uri(false)
      set_api_key
      CF.account_name = CF::Account.info.name
      run_title = options[:run_title].parameterize
      input_data = options[:input_data].presence
      
      if input_data =~ /^\// #checking absolute input data path
        input_data_file = input_data
      else
        unless File.exist?(input_data)
          say("The input data file named #{input_data} doesn't exist", :red) and return
        end
        input_data_file = "#{Dir.pwd}/#{input_data}"
      end
      units = CF::Run.add_units({:run_title => run_title, :file => input_data_file})
      if units['error'].present?
        say("Error: #{units['error']['message']}", :red) and exit(1)
      end

      # if result.status == "resumed"
      say("\"#{units['successfull']}\"!", :green)
      # end
    end 
  end
end