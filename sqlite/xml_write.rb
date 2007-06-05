
module Xml

    def Xml.write_tag(output, tag)
        output.write("    <tag k=\"#{tag[0]}\" v=\"#{tag[1]}\"/>\n")
    end

    def Xml.write_node(output, id, node)
        output.write("  <node id=\"#{id}\" lat=\"#{node.lat}\" lon=\"#{node.lon}\"")
        if node.tags.empty?
            #no tags so close node
            output.write("/>\n")
        else
            output.write(">\n")
            node.tags.each do |tag|
                write_tag(output, tag)
            end
            output.write("  </node>\n")
        end
    end

    def Xml.write_segment(output, id, segment)
        output.write("  <segment id=\"#{id}\" from=\"#{segment.node_a}\" to=\"#{segment.node_b}\"")
        if segment.tags.empty?
            #no tags so close segment
            output.write("/>\n")
        else
            output.write(">\n")
            segment.tags.each do |tag|
                write_tag(output, tag)
            end
            output.write("  </segment>\n")
        end
    end

    def Xml.write_way(output, id, way)
        output.write("  <way id=\"#{id}\">\n")
        #segments
        way.segments.each do |segment|
            output.write("    <seg id=\"#{segment}\"/>\n")
        end
        #tags
        way.tags.each do |tag|
            write_tag(output, tag)
        end
        output.write("  </way>\n")
        
    end

end