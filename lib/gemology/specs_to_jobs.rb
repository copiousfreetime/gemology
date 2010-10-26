require 'net/http'
require 'gemology/resque_job'
require 'gemology/rubygems_client'

module Gemology
  class SpecsToJobs
    include Logable

    def initialize
      @client = RubygemsClient.new
    end
   
    def destinations
      ::Gemology::ResqueJob.job_names
    end

    def valid_destination?( dest )
      destinations.include?( dest )
    end

    def submit_to( job )
      s = @client.specs
      logger.info "Submitting #{s.size} #{job} jobs"
      count = 0
      s.each do |a|
        spec = ::Gemology::SpecLite.new( *a )
        #Resqeue.enqueue( ResqueJob.get_classname( job ), spec.file_name )
        count += 1
      end
      logger.info "Finished submitting #{count} #{job} jobs"
    end
  end
end

