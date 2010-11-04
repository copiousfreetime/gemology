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
        ::Resque.enqueue( ResqueJob.get_subclass( job ), spec.file_name )
        count += 1
        if count % 5000 == 0 then
          logger.info " #{count} #{job} jobs submitted"
        end
      end
      logger.info "Finished submitting #{count} #{job} jobs"
    end
  end
end

