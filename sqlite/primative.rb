
# $Id$

class Primative
    attr_accessor :tags, :action

    def initialize
        @tags = Array.new
        @action = nil
    end
end

class Node < Primative
    #node primative
    attr_accessor :lat, :lon

    def initialize(lat, lon)
        super()
        @lat = lat
        @lon = lon
    end

end

class Segment < Primative
    #segment primative
    attr_accessor :node_a, :node_b
end

class Way < Primative
    #way primative
    attr_accessor :segments

    def initialize
        super
        @segments = Array.new
    end
end