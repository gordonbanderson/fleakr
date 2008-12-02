require File.dirname(__FILE__) + '/../test_helper'

class EmptyObject
  include Fleakr::Object
end

class FlickrObject
  
  include Fleakr::Object
  
  flickr_attribute :name
  flickr_attribute :description, :xpath => 'desc'
  flickr_attribute :id, :attribute => 'nsid'
  flickr_attribute :photoset_id, :xpath => 'photoset', :attribute => 'id'
  
end

module Fleakr
  class ObjectTest < Test::Unit::TestCase
    
    describe "A class method provided by the Flickr::Object module" do
   
      it "should have an empty list of attributes if none are supplied" do
        EmptyObject.attributes.should == []
      end
      
      it "should know the names of all its attributes" do
        FlickrObject.attributes.map {|a| a.name.to_s }.should == %w(name description id photoset_id)
      end
      
    end
    
    describe "An instance method provided by the Flickr::Object module" do
      
      it "should have default reader methods" do
        [:name, :description, :id, :photoset_id].each do |method_name|
          FlickrObject.new.respond_to?(method_name).should == true
        end
      end
      
      context "when populating data from an XML document" do
        before do
          xml = <<-XML
            <name>Fleakr</name>
            <desc>Awesome</desc>
            <photoset id="1" />
          XML

          @object = FlickrObject.new
          @object.populate_from(Hpricot.XML(xml))
        end
        
        it "should have the correct value for :name" do
          @object.name.should == 'Fleakr'
        end
        
        it "should have the correct value for :description" do
          @object.description.should == 'Awesome'
        end
        
        it "should have the correct value for :photoset_id" do
          @object.photoset_id.should == '1'
        end
        
        it "should have the correct value for :id" do
          document = Hpricot.XML('<object nsid="1" />').at('object')
          @object.populate_from(document)
          
          @object.id.should == '1'
        end
      end
      
      it "should populate its data from an XML document when initializing" do
        document = stub()
        FlickrObject.any_instance.expects(:populate_from).with(document)
        
        FlickrObject.new(document)
      end
      
      it "should not attempt to populate itself from an XML document if one is not available" do
        FlickrObject.any_instance.expects(:populate_from).never
        FlickrObject.new
      end
      
      
    end
    
  end
end