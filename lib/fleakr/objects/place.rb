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
      
      flickr_attribute :longitude, :latitude, :woeid
      flickr_attribute :place_type_id, :place_type, :timezone, :place_url
      flickr_attribute :name, :from => '.'

    end
    
  end
end