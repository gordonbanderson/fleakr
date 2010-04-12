require File.dirname(__FILE__) + '/../../../test_helper'

module Fleakr::Objects
  class PlaceTest < Test::Unit::TestCase

    context "The Place class" do
      #should_find_all :places, :by => :query, :call => 'places.find', :path => 'rsp/place'
      
      
      should_find_one :place, :by => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'
    end

  end
end

=begin
  #Find by woe id
  find_one :by_woe_id, :using => :woe_id, :call => 'places.getInfo', :path => 'rsp/place'

  #Find by place url
  find_one :by_url, :using => :url, :call => 'places.getInfoByUrl', :path => 'rsp/place'
  
  #Find by a search query
  find_all :by_query, :call => 'places.find', :path => 'places/place'
  
  #Find places that are the children of a given place and have public photographs
  find_all :children_with_public_photos, :using => :woe_id, :call=> 'places.getChildrenWithPhotosPublic',:path => 'places/place'

=end