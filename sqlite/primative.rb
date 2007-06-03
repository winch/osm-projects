
class Node
    attr_accessor :tags, :lat, :lon

    def initialize()
        @tags = Array.new
    end
end

class Segment
    attr_accessor :tags, :node_a, :node_b

    def initialize()
        @tags = Array.new
    end
end

class Way
    attr_accessor :segments, :tags

    def initialize()
        @segments = Array.new
        @tags = Array.new
    end
end