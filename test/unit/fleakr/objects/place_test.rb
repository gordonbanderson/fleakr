require File.dirname(__FILE__) + '/../../../test_helper'

module Fleakr::Objects
  class PlaceTest < Test::Unit::TestCase
    
    should_autoload_when_accessing :shapefile_url,:has_shapedata, :locality, :country, :region, :county, :with => :load_info

    context "The Place class" do
      should_find_all :places, :by => :query, :call => 'places.find', :path => 'rsp/places/place'
      should_find_all :places, :using => :place_type_id, :method_name => 'by_authenticated_user', :call => 'places.placesForUser', :path => 'rsp/places/place'
      should_find_all :places, :using => :place_type_id, :method_name => 'by_contacts_of_authenticated_user', :call => 'places.placesForContacts', :path => 'rsp/places/place'
      should_find_all :places,  :using => :woe_id, :method_name => 'children_with_photos_public',
          :call => 'places.getChildrenWithPhotosPublic', :path => 'rsp/places/place'
      
      should_find_all_with_multiple_parameters :places, :params => [:place_type_id, :woe_id],  :method_name => 'top_places',
        :call => 'places.getTopPlacesList', :path => 'rsp/places/place'
      
      should_find_all_with_multiple_parameters :places, :params => [:west,:east,:north,:south,:place_type_id],
        :flickr_params => {:bbox => "1,1,1,1", :place_type_id => '1'}, 
        :method_name => 'by_bounding_box', :call => 'places.placesForBoundingBox', :path => 'rsp/places/place'
      
      should_find_one :place, :by => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'
      should_find_one :place, :by => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
      
      
      #should_find_one_with_multiple_parameters :places, :params => [:latitude,:longitude,:accuracy],
      #:flickr_params => {:lat => "1", :lon => '1', :accuracy => '1'},
      #  :method_name => 'by_coordinate', :call => 'places.findByLatLon', :path => 'rsp/places/place'
        
      #TO TEST
      #find_all_by_contacts_of_authenticated_user
      #find_one_by_coordinate 
      #photos within radius
      

      should_find_all_with_multiple_parameters :places, :method_name => 'by_tags', :params => [:place_type_id, :tags],
          :call => 'places.placesForTags', :path => 'rsp/places/place', :flickr_param => {:place_type_id => 8, :tags=>'1'}
    end
    
    
    
    context "An instance of the Place class" do
      setup do
        @place = Place::new
        @place.woe_id = 19135
      end
      
      context "when populating from the places_find XML data" do
        setup do
          @object = Place.new(Hpricot.XML(read_fixture('places.find')).at('rsp/places/place'))
        end
        
        should_have_a_value_for :latitude   => '50.782'
        should_have_a_value_for :longitude  => '0.290'
        should_have_a_value_for :place_id   => 'O8Jf6HCYCJ3dUw'
        should_have_a_value_for :timezone  => 'Europe/London'
        should_have_a_value_for :woe_id  => '19135'
        should_have_a_value_for :place_url  => '/United+Kingdom/England/Eastbourne'
        should_have_a_value_for :place_type  => 'locality'
        should_have_a_value_for :place_type_id  => '7'
        should_have_a_value_for :name  => 'Eastbourne, England, United Kingdom'
        
      end
      
      should "have tags" do
        response = mock_request_cycle :for => 'places.tagsForPlace', :with => {:woe_id => 19135}
        stubs = []
        elements = (response.body/'rsp/tags/tag').map
        elements.each do |element|
          stub = stub()
          stubs << stub
          Tag.expects(:new).with(element).returns(stub)
        end
        @place.tags.should == stubs
      end
    end
    
    
    
  end

end
