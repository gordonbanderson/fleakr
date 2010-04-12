require File.dirname(__FILE__) + '/../../../test_helper'

module Fleakr::Objects
  class PlaceTest < Test::Unit::TestCase

    context "The Place class" do
      #should_find_all :places, :by => :query, :call => 'places.find', :path => 'rsp/place'
      
      
      should_find_one :place, :by => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'
      should_find_one :place, :by => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
    end

  end
end
