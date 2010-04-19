module Fleakr
  module Objects # :nodoc:

    # = Accuracy
    # n. World level is 1, Country is ~3, Region ~6, City ~11, Street ~16. Current range is 1-16. 
    # This class represents an accuracy, and merely holds constants to avoid remembering numbers in the Flickr API
    class Accuracy
      # Accuracy representing the world
      WORLD = 1
      
      # Accuracy representing the a country
      COUNTRY = 3
      
      # Accuracy representing a region
      REGION = 6
      
      # Accuracy representing a city
      CITY = 11
      
      # Accuracy representing a street
      STREET = 16
    end
  end
end