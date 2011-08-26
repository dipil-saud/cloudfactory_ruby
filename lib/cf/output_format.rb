module CF
  class OutputFormat
    require 'httparty'
    include Client

    # type of the station, e.g. station = Station.new({:type => "Work"})
    attr_accessor :settings, :errors, :line, :output_formats_settings
    
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