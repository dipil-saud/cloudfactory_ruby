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
      
      if File.exist?("#{yaml_source}")
        line_yaml_dump = YAML::load(File.read(yaml_source).strip)
        line_title = line_yaml_dump['title'].parameterize        
        line = CF::Line.find(line_title)
        line = Hashie::Mash.new(line)
        if line.error.blank?
          line_title = line_title
        else
          say("#{line.error.message}", :red) and return
        end
      elsif options[:line].present?
        line = CF::Line.find(options[:line])
        line = Hashie::Mash.new(line)
        if line.error.blank?
          line_title = options[:line]
        else
          say("#{line.error.message}", :red) and return
        end
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
      

      # before starting the run creation process, we need to make sure whether the line exists or not
      # if not, then we got to first create the line and then do the production run
      # else we just simply do the production run
      
      if line.error.blank?
        say "Creating a production run with title #{run_title}", :green
        run = CF::Run.create(line_title, run_title, input_data_file)
        if run.errors.blank?
          display_success_run(run)
        else
          say("Error: #{run.errors}", :red)
        end
      else
        if File.exist?("#{yaml_source}") and !line_title =~ /\w\/\w/
          # first create line only if its in the valid line directory
          say("Creating the line: #{line_title}", :green)
          Cf::Line.new.create
          # Now create a production run with the title run_title
          say "Creating a production run with title #{run_title}", :green
          run = CF::Run.create(CF::Line.info(line_title), run_title, input_data_file)
          if run.errors.blank?
            display_success_run(run)
          else
            say("Error: #{run.errors}", :red)
          end
        end
      end
    end

    no_tasks do
      def display_success_run(run)
        say("Run created successfully.", :green)
        say("View your production at:\n\thttp://#{CF.account_name}.#{CF.api_url.split("/")[-2]}/runs/#{CF.account_name}/#{run.title}/workerpool_preview\n", :green)
      end
    end
    
    desc "production list", "list the production runs"
    method_option :line, :type => :string, :aliases => "-l", :desc => "the title of the line"
    method_option :page, :type => :numeric, :aliases => "-p", :desc => "page number"
    def list
      set_target_uri(false)
      set_api_key
      CF.account_name = CF::Account.info.name
      if options['line'].present?
        line_title = options['line'].parameterize
        runs = CF::Run.all(:line_title => line_title)
      else
        runs = CF::Run.all
      end

      unless runs.kind_of?(Array)
        if runs.error.present?
          say("No Runs\n#{runs.error.message}", :red) and exit(1)
        end
      end

      runs.sort! {|a, b| a[:name] <=> b[:name] }
      runs_table = table do |t|
        t.headings = ["Run Title", 'URL']
        runs.each do |run|
          run = Hashie::Mash.new(run)
          t << [run.title, "http://#{CF.account_name}.cloudfactory.com/runs/#{CF.account_name}/#{run.title}"]
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
  end
end