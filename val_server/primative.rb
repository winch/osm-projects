
#Objects representing OSM data primatives
#http://wiki.openstreetmap.org/index.php/Data_Primitives

#cgi required for escapeHTML method used to escape tag values
require 'cgi'

#Base primative class
class Primative
    #id
    attr_accessor :id
    #version
    attr_accessor :version
    #changeset
    attr_accessor :changeset
    #array containing tags as key, value pairs.
    attr_accessor :tags
    #if !nil value will be written in action attribute when output as osm xml.
    #osm xml can then be loaded in JOSM and action performed when uploaded.
    attr_accessor :action

    def initialize
        @tags = Array.new
        @action = nil
    end

    #The same tags in a different order are considered equal.
    def ==(other)
        if @id != other.id
            return false
        end
        equal = true
        @tags.each do |tag|
            if other.tags.index(tag).nil?
                equal = false
            end
        end
        other.tags.each do |tag|
            if @tags.index(tag).nil?
                equal = false
            end
        end
        equal
    end

    #returns the tags in osm xml
    def to_xml
        xml = ''
        @tags.each do |tag|
            if tag[0] != nil && tag[1] != nil
                xml << "    <tag k=\"#{tag[0]}\" v=\"#{CGI.escapeHTML(tag[1])}\"/>\n"
            else
                puts "id |#{@id}| tag[0] |#{tag[0]}| tag[1] |#{tag[1]}|"
            end
        end
        xml
    end

end

#Node data primative
class Node < Primative
    #lattitute of node
    attr_accessor :lat
    #longitude of note
    attr_accessor :lon

    def initialize(lat, lon)
        super()
        @lat = lat
        @lon = lon
    end

    def ==(other)
        if (@lat == other.lat) && (@lon == other.lon)
            return super(other)
        end
        false
    end

    #returns node in osm xml
    def to_xml
        action = ' '
        if !@action.nil?
            action = " action=\"#{@action}\" "
        end
        xml = "  <node id=\"#{@id}\"#{action}lat=\"#{@lat}\" lon=\"#{@lon}\" version=\"#{@version}\""
        if @tags.empty?
            #no tags so close node
            xml << "/>\n"
        else
            xml << ">\n"
            xml << super << "  </node>\n"
        end
        xml
    end

end

#way data primative
class Way < Primative
    #list of segments that make up the way
    attr_accessor :nodes

    def initialize
        super
        @nodes = Array.new
    end

    def ==(other)
        if (@nodes == other.nodes)
            return super(other)
        end
        false
    end

    #returns way in osm xml
    def to_xml
        action = ''
        if !@action.nil?
            action = "action=\"#{@action}\" "
        end
        xml = "  <way id=\"#{@id}\" #{action}version=\"#{@version}\">\n"
        @nodes.each do |node|
            xml << "    <nd ref=\"#{node}\"/>\n"
        end
        xml << super << "  </way>\n"
    end
end

#relation data primative
class Relation < Primative
    #list of nodes
    attr_accessor :members

    def initialize
        super
        @members = Array.new
    end

    def ==(other)
        if (@members == other.members)
            return super(other)
        end
        false
    end

    #returns relation in osm xml
    def to_xml
        action = ''
        if !@action.nil?
            action = " action=\"#{@action}\""
        end
        xml = "  <relation id=\"#{id}\"#{action}>\n"
        @members.each do |member|
            xml << "<member type=\"#{member.type}\" ref=\"#{member.ref}\" role=\"#{member.role}\" />\n"
        end
        xml << super << "  </relation>\n"
    end
end

#relation member data primative
class Member
    attr_accessor :type
    attr_accessor :ref
    attr_accessor :role

    def initialize(type, ref, role)
        @type = type
        @ref = ref
        @role = role
    end

    def ==(other)
        if (@type == other.type) && (@ref == other.ref) && (@role == other.role)
            return true
        end
        false
    end
end

#changeset data primative

class Changeset < Primative
    attr_accessor :status

    def initialize()
        super
    end

    #returns changeset in osm xml
    def to_xml
        xml = "  <changeset id=\"#{@id}\""
        if @tags.empty?
            #no tags so close node
            xml << "/>\n"
        else
            xml << ">\n"
            xml << super << "  </changeset>\n"
        end
        xml
    end

end

