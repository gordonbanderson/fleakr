module Fleakr
  module Objects # :nodoc:

    # = PlaceType
    #
    # This class represents a place type
    #
    # == Attributes
    #
    # [name] The name of the place type
    # [place_type_id] Internal flickr id of the place type
    #
    class PlaceType
      include Fleakr::Support::Object
      
      # Constant to indicate the place type is a neighbourhood
      NEIGHBOURHOOD=22
      
      # Constant to indicate the place type is a locality
      LOCALITY = 7
      
      # Constant to indicate the place type is a county
      COUNTY = 9
      
      # Constant to indicate the place type is a region
      REGION = 8
      
      # Constant to indicate the place type is a country
      COUNTRY = 12
      
      # Constant to indicate the place type is a continent
      CONTINENT = 29
      
      #If a place comes from a text search then it will have less information than the getInfo method.  use this flag so
      #as to know when to lazily called getInfo
      @brief = true
      
      flickr_attribute :id
      flickr_attribute :name, :from => '.'
      
      #Find all the place types by calling the API
      def self.find_all
        response = Fleakr::Api::MethodRequest.with_response!('places.getPlaceTypes')
        (response.body/'place_types/place_type').map {|e| PlaceType.new(e) }
      end
    end
  end 
end