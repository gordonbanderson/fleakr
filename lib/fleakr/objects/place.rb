module Fleakr
  module Objects # :nodoc:

    # = Place
    #
    # This class represents a place.  One can create them by calling
    # <ruby>
    # Fleakr.find_places("Wellington")
    #</ruby>
    #
    # == Attributes
    #
    # [name] The name of the place
    # [latitude] Latitude of place
    # [longitude] Longitude of place
    # [place_type] Place type (e.g. 'neighbourhood')
    # [place_type_id]  Internal Flickr id of place type
    # [timezone] The name of the Timezone, e.g. 'Pacific/Auckland'
    # [place_url] The place as a URL
    # [raw] The raw, user-entered value for this tag
    # [value] The formatted value for this tag. Also available through <tt>to_s</tt>
    #
    class Place
      
      include Fleakr::Support::Object
      
      #If a place comes from a text search then it will have less information than the getInfo method.  use this flag so
      #as to know when to lazily called getInfo
      @brief = true
      
      flickr_attribute :longitude, :latitude, :woeid
      flickr_attribute :place_type_id, :place_type, :timezone, :place_url
      flickr_attribute :name, :from => ['name']
      
      #Find by woe id
      find_one :by_woe_id, :using => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'
      
      #Find by a search query
      find_all :by_query, :call => 'places.find', :path => 'places/place'

      
      def initialize(document = nil, options = {})
        puts "IN PLACE OVERRIDE METHOD"
        self.populate_from(document) unless document.nil?
        @authentication_options = options.extract!(:auth_token)
        
        if @name.blank?
          puts "BLANK NAME :( *********"
          @name = document.at('.').inner_text
        else
          @brief = false
        end
        
        puts "BRIEF:#{@brief}"
      end
    end
    
  end
end