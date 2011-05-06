module CloudFactory
  class InputHeader

    # label for the input_header, e.g. :label => "image_url"
    attr_accessor :label
    
    # field_type for the input_header, e.g. :field_type => "text_data"
    attr_accessor :field_type
    
    # value or source for the input_header, e.g. :value => "http://s3.amazon.com/bizcardarmy/medium/.."
    attr_accessor :value
    
    # required boolean either true or false , e.g. :required => "true" & if false then you don't need to mention
    attr_accessor :required
    
    # validation_format format of the source for the input_header, e.g. :validation_format => "url"
    attr_accessor :validation_format
    
    # =InputHeader class for CloudFactory api entities.
    # ==Initializes a new input_header
    # * Syntax for creating new input_header: <b>InputHeader.new(</b> Hash <b>)</b>
    # ==Usage Example:
    #   attrs = {:label => "image_url",
    #     :field_type => "text_data",
    #     :value => "http://s3.amazon.com/bizcardarmy/medium/1.jpg",
    #     :required => true,
    #     :validation_format => "url"} 
    #
    #   input_header = InputHeader.new(attrs)
    def initialize(options={})
      @label              = options[:label]
      @field_type         = options[:field_type]
      @value              = options[:value]
      @required           = options[:required]
      @validation_format  = options[:validation_format]
    end
  end
end