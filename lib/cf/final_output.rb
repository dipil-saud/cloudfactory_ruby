module CF
  class FinalOutput
    include Client
    attr_accessor :final_outputs, :unit_id, :final_output, :output
    
    # def self.get_result(run_id)
    #       resp = get("/runs/#{run_id}/results.json")
    #       
    #       @final_output =[]
    #       resp.each do |r|
    #         result = self.new()
    #         r.to_hash.each_pair do |k,v|
    #           result.send("#{k}=",v) if result.respond_to?(k)
    #         end
    #         @results << result
    #       end
    #       return @results
    #     end
  end
end