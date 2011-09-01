module CF
  class InputFormat
    include Client

    # name for the input_format, e.g. :name => "image_url"
    attr_accessor :name
    
    # required boolean either true or false , e.g. :required => "true" & if false then you don't need to mention
    attr_accessor :required
    
    # valid_type format of the source for the input_format, e.g. :valid_type => "url"
    attr_accessor :valid_type
    
    # ID of an input_format 
    attr_accessor :id
    
    # Title of Line with which input_format is associated
    attr_accessor :line_title
    
    # Contains error message if any
    attr_accessor :errors
    
    # ==Initializes a new input_format
    # ===Usage Example:
    #   line = CF::Line.create("Digitize", "Survey")
    #
    #   attrs = 
    #   {
    #     :name => "image_url",
    #     :required => true,
    #     :valid_type => "url"
    #   } 
    #   
    #   input_format = CF::InputFormat.new(attrs) 
    #   line.input_formats input_format
    def initialize(options={})
      @station            = options[:station]
      @line               = options[:line]
      @name              = options[:name]
      @required           = options[:required]
      @valid_type  = options[:valid_type].nil? ? nil : options[:valid_type]
      if !@station.nil? or !@line.nil?
        line_title = @station.nil? ? @line.title : @station.line_title
        if @valid_type
          @resp = self.class.post("/lines/#{CF.account_name}/#{@line.title.downcase}/input_formats.json", :input_format => {:name => @name, :required => @required, :valid_type => @valid_type})
        else
          @resp = self.class.post("/lines/#{CF.account_name}/#{@line.title.downcase}/input_formats.json", :input_format => {:name => @name, :required => @required})
        end
        @resp.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        if @resp.code != 200
          self.errors = @resp.error.message
        end
        @line_title = line_title
        if !@station.nil? && @station.except.nil? && @station.extra.nil?
          @station.input_formats = self
        else
          @line.input_formats = self
        end
      end
    end
    
    # ==Returns all the input headers of a specific line
    # ===Usage Example:
    #   line = CF::Line.new("Digitize Card","Survey")
    #
    #   attrs_1 = 
    #   {
    #     :name => "image_url",
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   attrs_2 = 
    #   {
    #     :name => "text_url", 
    #     :required => true, 
    #     :valid_type => "url"
    #   }
    #   
    #   input_format_1 = CF::InputFormat.new(attrs_1)
    #   line.input_formats input_format_1
    #   input_format_2 = CF::InputFormat.new(attrs_2)
    #   line.input_formats input_format_2
    # 
    #   input_formats_of_line = CF::InputFormat.all(line)
    # returns an array of input headers associated with line
    def self.all(line)
      get("/lines/#{CF.account_name}/#{line.title.downcase}/input_formats.json")
    end
    
    def to_s # :nodoc:
      "{:id => #{self.id}, :name => #{self.name}, :required => #{self.required}, :valid_type => #{self.valid_type}, :errors => #{self.errors}}"
    end
  end
end