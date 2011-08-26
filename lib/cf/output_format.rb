module CF
  class OutputFormat
    require 'httparty'
    include Client

    # output_format settings
    attr_accessor :settings
    
    # Contains error message if any
    attr_accessor :errors
    
    # Line object for which output_format is specified
    attr_accessor :line
    
    # ==Specifies output format for a line
    # ===Usage Example:
    #   output_format = CF::OutputFormat.new({:station_1 => [{:name => "First Name"}],:station_2 => [{:name => "Mobile", :except => true}]})
    #   line.output_formats output_format
    def initialize(options={})
      if !options.blank?
        @settings = options
        @line = options[:line] if options[:line].nil? ? nil : options[:line]
        if !@line.nil?
          options.delete(:line)
          request = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :output_formats => options
            }
          }
          resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@line.title.downcase}/output_format.json",request)
          self.errors = resp.parsed_response['error']['message'] if resp.code != 200
          self.line.output_formats = self
        end
      end
    end
  end
end