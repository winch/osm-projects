
class DatabaseMap < Database

    def initialize(file_name)
        super(file_name)
    end
    
    #-1.1639586790123457 - 51.894554970370365 - -1.1312473209876546 - 51.92318702962963
    
    #find all nodes in bbox
    def find_node_at(bbox)
        @db.execute('SELECT id, lat, lon FROM node WHERE lat < ? and lat > ? and
                    lon > ? and lon < ?', bbox[3], bbox[1], bbox[0], bbox[2]) do |node|
            primative = Node.new(node[1], node[2])
            primative.id = node[0]
            yield(primative)
        end
    end

end
