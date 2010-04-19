require File.dirname(__FILE__) + '/../../../test_helper'

module Fleakr::Objects
  class PlaceTypeTest < Test::Unit::TestCase
    
    context "The PlaceType class" do
      #should_find_all :place_types, :method_name => 'find_all', :call => 'places.getPlaceTypes', :path => 'rsp/place_types/place_type'

      should "be able to find all the place types" do
         response = mock_request_cycle :for => 'places.getPlaceTypes'

         stubs = []
         path = 'rsp/place_types/place_type'
         elements = (response.body/path).map


         elements.each do |element|
           stub = stub()
           stubs << stub
           PlaceType.expects(:new).with(element).returns(stub)
         end

         PlaceType.find_all.should == stubs
      end

    end
    
    context "An instance of the PlaceType class" do
      setup do
        @place_type = PlaceType::new
      end
      
      context "when populating from the places get place types  XML data" do
        setup do
          @object = Place.new(Hpricot.XML(read_fixture('places.getPlaceTypes')).at('rsp/place_types/place_type'))
        end
        
        should_have_a_value_for :name   => 'neighbourhood'
        
      end
    end
  end

end
