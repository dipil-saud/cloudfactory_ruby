module CF
  class HumanWorker
    include Client
    require 'httparty'
    extend ActiveSupport::Concern
    
    attr_accessor :number, :reward, :station, :stat_badge, :skill_badges, :badge, :errors
    
    def initialize(options={})
      @station = options[:station]
      @number  = options[:number].nil? ? 1 : options[:number]
      @reward  = options[:reward]
      @badge = options[:badge].nil? ? nil : options[:badge]
      if @station
        if @badge.nil?
          request = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"}
            }
          }
        else
          request = 
          {
            :body => 
            {
              :api_key => CF.api_key,
              :worker => {:number => @number, :reward => @reward, :type => "HumanWorker"},
              :badge => @badge
            }
          }
        end
        resp = HTTParty.post("#{CF.api_url}#{CF.api_version}/lines/#{CF.account_name}/#{@station.line['title'].downcase}/stations/#{@station.index}/workers.json",request)
        resp.parsed_response.to_hash.each_pair do |k,v|
          self.send("#{k}=",v) if self.respond_to?(k)
        end
        if resp.code != 200
          self.errors = resp.parsed_response['error']['message']
        end
        self.station = options[:station]
        self.station.worker = self
      end
    end
  end
end