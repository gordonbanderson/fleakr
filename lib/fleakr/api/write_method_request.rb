module Fleakr
  module Api # :nodoc:
    
    # = WriteRequest
    # 
    # This implements the upload functionality of the Flickr API which is needed
    # to create new photos and replace the photo content of existing photos
    #
    class WriteMethodRequest

      include Fleakr::Support::Request


      attr_reader :parameters, :method

      # Send a request and return a Response object.  If an API error occurs, this raises
      # a Fleakr::ApiError with the reason for the error.  See WriteRequest#new for more 
      # details.
      #
      def self.with_response!(desired_method, options = {})
        request = self.new(options)
        request.method = desired_method
        
        response = request.send
        
        logger.debug "@method is #{@method}"
        
        raise(Fleakr::ApiError, "Code: #{response.error.code} - #{response.error.message}") if response.error?

        response
      end
      
      def method=(method) # :nodoc:
        @method = method.sub(/^(flickr\.)?/, 'flickr.')
        parameters.add_option(:method, @method)
      end
      
      # Create a new WriteRequest with the specified filename, type, and options.  Type
      # is one of <tt>:create</tt> or <tt>:update</tt> to specify whether we are saving a new
      # image or replacing an existing one.  
      #
      # For a list of available options, see the documentation in the relevant method
      #
      def initialize(options = {})
        @parameters = ParameterList.new(options)
      end

      def headers # :nodoc:
        {'Content-Type' => "multipart/form-data; boundary=#{self.parameters.boundary}"}
      end

      def headers # :nodoc:
        {'Content-Type' => "multipart/form-data; boundary=#{self.parameters.boundary}"}
      end

      def send # :nodoc:
        logger.debug "ENDPOINT URI:#{endpoint_uri.host}"
        logger.info("Sending write request to: #{endpoint_uri}")
        logger.debug("Request data:\n#{self.parameters.to_form}")

        response = Net::HTTP.start(endpoint_uri.host, endpoint_uri.port) do |http| 
          logger.info("Sending upload request to: #{endpoint_uri}")
          logger.debug("Request data:\n#{self.parameters.to_form}")
          logger.debug("Request headers:\n#{self.headers.inspect}")
          http.post(endpoint_uri.path, self.parameters.to_form, self.headers)
        end
        
        Response.new(response.body)
        
      end
      
      def endpoint_url
        'http://api.flickr.com/services/rest/'
      end
      

    end
    
  end
end