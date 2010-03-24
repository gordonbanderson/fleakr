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
      
      flickr_attribute :longitude, :latitude, :woeid, :place_id
      flickr_attribute :place_type_id, :place_type, :timezone, :place_url
      flickr_attribute :photo_count # Only happens with places.placesForTags call
      flickr_attribute :name, :from => ['name']
      
      #From the full version of a place
      flickr_attribute :timezone, :has_shapedata
      flickr_attribute :shapefile_url, :from => 'place/shapedata/urls/shapefile'
      
  
      lazily_load :timezone, :has_shapedata, :shapefile_url, :with => :load_info
      
      scoped_search
      
=begin
<?xml version="1.0" encoding="utf-8" ?>
<rsp stat="ok">
<place place_id="05s_Z7KaBJlofQ" woeid="35567" latitude="56.339" longitude="-2.796" 
place_url="/United+Kingdom/Scotland/St.+Andrews" place_type="locality" place_type_id="7" 
timezone="Europe/London" name="St. Andrews, Scotland, United Kingdom" has_shapedata="1">
     <locality place_id="05s_Z7KaBJlofQ" woeid="35567" latitude="56.339" longitude="-2.796" 
     place_url="/United+Kingdom/Scotland/St.+Andrews">St. Andrews, Scotland, United Kingdom
     </locality>
     <county place_id="P8fAbESYA5q7lBUAPw" woeid="12602201" latitude="56.229" longitude="-3.161" place_url="/P8fAbESYA5q7lBUAPw">Fife, Scotland, United Kingdom</county>
     <region place_id="yw00oOWYA5mnH740VQ" woeid="12578048" latitude="56.652" longitude="-3.996" place_url="/United+Kingdom/Scotland">Scotland, United Kingdom</region>
     <country place_id="DevLebebApj4RVbtaQ" woeid="23424975" latitude="54.314" longitude="-2.230" place_url="/United+Kingdom">United Kingdom</country>
     <shapedata created="1247719263" alpha="0.00015" count_points="2116" count_edges="41" has_donuthole="0" is_donuthole="0">
             <polylines>
                     <polyline>56.366817474365,-2.819885969162 56.366962432861,-2.819365978241 56.365249633789,-2.8135290145874 56.365440368652,-2.8102679252625 56.361637115479,-2.8058910369873 56.360969543457,-2.8044309616089 56.353839874268,-2.7973930835724 56.345275878906,-2.7912130355835 56.343467712402,-2.7874369621277 56.341567993164,-2.7835750579834 56.342540740967,-2.7716009616852 56.334098815918,-2.758425951004 56.332599639893,-2.7486839294434 56.329578399658,-2.7411739826202 56.325199127197,-2.736711025238 56.324142456055,-2.7269690036774 56.326782226562,-2.7211329936981 56.327613830566,-2.7188580036163 56.328186035156,-2.7084300518036 56.312297821045,-2.7154250144958 56.305755615234,-2.7342491149902 56.302967071533,-2.7567100524902 56.321628570557,-2.7493278980255 56.328147888184,-2.7575249671936 56.326770782471,-2.7675240039825 56.321105957031,-2.7771370410919 56.317867279053,-2.7902688980103 56.320343017578,-2.7973930835724 56.320022583008,-2.8171129226685 56.313159942627,-2.8224630355835 56.313167572021,-2.8224999904633 56.331684112549,-2.8289999961853 56.320350646973,-2.8453669548035 56.331954956055,-2.8516380786896 56.334987640381,-2.8428189754486 56.351791381836,-2.8380770683289 56.36429977417,-2.8399651050568 56.36389541626,-2.834214925766 56.364490509033,-2.8283779621124 56.365737915039,-2.8253529071808 56.366817474365,-2.819885969162</polyline>
             </polylines>
             <urls>
                     <shapefile>http://farm3.static.flickr.com/2653/shapefiles/35567_20090716_d8d512008b.tar.gz</shapefile>
             </urls>
     </shapedata>
</place>
</rsp>
=end
      
      #Find by woe id
      find_one :by_woe_id, :using => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'

      #Find by place url
      find_one :by_url, :using => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
      
      #Find by a search query
      find_all :by_query, :call => 'places.find', :path => 'places/place'

      #Find places that are the children of a given place and have public photographs
      find_all :children_with_public_photos, :using => :woe_id, :call=> 'places.getChildrenWithPhotosPublic',:path => 'places/place'
     
      
      def load_info # :nodoc:
        response = Fleakr::Api::MethodRequest.with_response!('places.getInfo', :woe_id => self.woeid)
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
      
      def locality
        @locality
      end
      
      def region
        @region
      end
      
      def country
        @country
      end
      
      def county
        @county
      end
      
      
      
      def self.find_all_by_tags(tags, place_type_id, woe_id = nil)
        puts "WOE ID:#{woe_id}"
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForTags', :tags => tags, :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForTags', :woe_id => woe_id, :tags => tags, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end
      
      #This returns places for the currently authenticated user
      def self.find_all_by_authenticated_user(place_type_id = 8, woe_id = nil)
        puts "WOE ID:#{woe_id}"
        if woe_id.blank?
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForUser', :place_type_id => place_type_id)
        else
          response = Fleakr::Api::MethodRequest.with_response!('places.placesForUser', :woe_id => woe_id, :place_type_id => place_type_id)
        end
        (response.body/'places/place').map {|e| Place.new(e) }
      end



      # A list of related tags.  Each of the objects in the collection is an instance of Tag
      #
      def tags
        @tags ||= begin
          Tag.find_all_by_woe_id(@woeid)
        end
      end
      
      #Overcome issue with name being an attribute or a text node depending on call used
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