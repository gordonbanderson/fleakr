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
      
      flickr_attribute :longitude, :latitude, :place_id
      flickr_attribute :place_type_id, :place_type, :timezone, :place_url
      flickr_attribute :photo_count # Only happens with places.placesForTags call
      flickr_attribute :name, :from => ['name']
      flickr_attribute :woe_id, :from => ['woeid']
      
      #From the full version of a place
      flickr_attribute :county, :country, :locality, :region
      flickr_attribute :timezone, :has_shapedata
      flickr_attribute :shapefile_url, :from => 'place/shapedata/urls/shapefile'
      
  
      lazily_load :has_shapedata, :shapefile_url, :county, :country, :locality, :region, :with => :load_info
      
      scoped_search

      #Find by woe id
      find_one :by_woe_id, :using => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'

      #Find by place url
      find_one :by_url, :using => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
      
      #Find by a search query
      find_all :by_query, :call => 'places.find', :path => 'places/place'
      
      #Find places that are the children of a given place and have public photographs
      find_all :children_with_public_photos, :using => :woe_id, :call=> 'places.getChildrenWithPhotosPublic',:path => 'places/place'
      
      
      # Use the flickr search API to find all photos associated with this place
      def photos
        photos = Fleakr::Objects::Photo.find_all_by_search(:woe_id => woeid)
      end
      
      #Use the flickr search API to find all photos with a radius of the centre point of the place
      def photos_within_radius(radius_km)
        Fleakr::Objects::Photo.find_all_by_search(:latitude => @latitude, :longitude => @longitude, :radius => radius_km)
      end
      
      def load_info # :nodoc:
        response = Fleakr::Api::MethodRequest.with_response!('places.getInfo', :woe_id => self.woe_id)
        self.populate_from(response.body)
        
        #Grab the other items related to this, ie country, locality etc
        locality_node = response.body/'rsp/place/locality'
        @locality = Place.new(locality_node) if locality_node.to_s.strip != ''
        
        county_node = response.body/'rsp/place/county'
        @county = Place.new(county_node) if county_node.to_s.strip != ''
        
        region_node = response.body/'rsp/place/region'
        @region = Place.new(region_node) if region_node.to_s.strip != ''
        
        country_node = response.body/'rsp/place/country'
        @country = Place.new(country_node) if country_node.to_s.strip != ''
        
      end
 
      
      
      def self.find_all_by_tags(tags, options={})
        #options[:place_type_id] = 8 if options[:place_type_id] == nil
        place_type_id = 8
        place_type_id = options[:place_type_id] if options[:place_type_id] != nil
        woe_id = options[:woe_id]
        
        
        
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForTags', :tags => tags, :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForTags', :woe_id => woe_id, :tags => tags, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end
      
      
      #This returns places for the currently authenticated user
      def self.find_all_by_authenticated_user(place_type_id = 8, woe_id = nil)
        puts "FIND ALL BY AUTH"
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForUser', :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForUser', :woe_id => woe_id, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end
      
      #This returns places for the contacts of the currently authenticated user
      def self.find_all_by_contacts_of_authenticated_user(place_type_id = 8, woe_id = nil)
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForContacts', :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForContacts', :woe_id => woe_id, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end
      
      
      #Return top geotagged places for the previous day
      def self.find_top_places(place_type_id = 8, woe_id = nil)
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.getTopPlacesList', :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.getTopPlacesList', :woe_id => woe_id, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end

      # Find places by searching within a bounding box
      #FIXME - this should return only one
      def self.find_by_lat_lon(options)
        options[:accuracy] = 16 if options[:accuracy] == nil
        
        response = Fleakr::Api::MethodRequest.with_response!('places.findByLatLon', 
        :accuracy => options[:accuracy], :lon => options[:lon], :lat => options[:lat])
        
        #There should only be one result, so only return first
        (response.body/'rsp/places/place').map {|e| Fleakr::Objects::Place.new(e) } [0]
      end


      # Find places by searching within a bounding box
      def self.find_places_by_bounding_box(min_longitude, min_latitude, max_longitude, max_latitude,place_type_id=8)
        bbox_string = "#{min_longitude},#{min_latitude},#{max_longitude},#{max_latitude}"
        response = Fleakr::Api::MethodRequest.with_response!('places.placesForBoundingBox', 
        :place_type_id => place_type_id, :bbox=>bbox_string)
        (response.body/'rsp/places/place').map {|e| Fleakr::Objects::Place.new(e) }
      end



      # A list of related tags.  Each of the objects in the collection is an instance of Tag
      def tags
        @tags ||= begin
          Tag.find_all_by_woe_id(@woe_id)
        end
      end
      
      #Overcome issue with name being an attribute or a text node depending on call used
      def initialize(document = nil, options = {})
        if document != nil
          self.populate_from(document) unless document.nil?
          if @name.blank?
            @name = document.at('.').inner_text
          else
            @brief = false
          end
        
        end
        @authentication_options = options.extract!(:auth_token)
      end
    end
    
  end
end