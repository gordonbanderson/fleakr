require File.dirname(__FILE__) + '/../../../test_helper'

module Fleakr::Objects
  class PlaceTest < Test::Unit::TestCase

    context "The Place class" do
      #should_find_all :places, :by => :query, :call => 'places.find', :path => 'rsp/place'
      
      
      should_find_one :place, :by => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'
      should_find_one :place, :by => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
    end
    
    
    
    context "An instance of the Place class" do
      
      setup { @place = Place.new }
      
      context "when populating from the places_getInfo XML data" do
        setup do
          @object = Place.new(Hpricot.XML(read_fixture('places.getInfo')).at('rsp/place'))
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
    end

  end
end
