
class XMLListener

    attr_reader :primative

    def initialize(type, found)
        @primative_type = type
        @found = found
        @primative = nil
        @tag = nil
        @tag_id = nil
    end

    def tag_start(name, attrs)
        case name
        when 'osm'
            #ignore osm tag
        when 'node'
            #set current tag
            raise 'primative within primative' if @tag.nil? == false
            raise "Looking for #{@primative_type} but found node" if @primative_type != 'node' && @primative_type.nil? == false
            @tag = 'node'
            @tag_id = attrs['id']
            @primative = Node.new(attrs['lat'], attrs['lon'])
            @primative.id = attrs['id']
        when 'way'
            raise 'primative within primative' if @tag.nil? == false
            raise "Looking for #{@primative_type} but found way" if @primative_type != 'way' && @primative_type.nil? == false
            @tag = 'way'
            @tag_id = attrs['id']
            @primative = Way.new()
            @primative.id = attrs['id']
        when 'nd'
            raise 'node not in way' if @tag != 'way'
            #import way node
            @primative.nodes.push(attrs['ref'])
        when 'relation'
            raise 'primative within primative' if @tag.nil? == false
            raise "Looking for #{@primative_type} but found relation" if @primative_type != 'relation' && @primative_type.nil? == false
            @tag = 'relation'
            @primative =  Relation.new()
            @primative_id = attrs['id']
        when 'member'
            raise "member #{attrs} without parent relation" if @tag != 'relation'
            case attrs['type']
            when 'node'
                #@importer.import_node_relation(@tag_id, attrs['ref'], attrs['role'])
            when 'way'
                #@importer.import_way_relation(@tag_id, attrs['ref'], attrs['role'])
            end
        when 'changeset'
            raise 'primative within primative' if @tag.nil? == false
            raise "Looking for #{@primative_type} but found changeset" if @primative_type != 'changeset' && @primative_type.nil? == false
            @tag = 'changeset'
            @primative = Changeset.new()
            @primative_id = attrs['id']
        when 'tag'
            raise 'tag without parent' if @tag.nil?
            #add tag to primative
            @primative.tags.push([attrs['k'], attrs['v']])
        else
            puts "Unrecognised tag <#{name}>"
        end
    end

    def tag_end(name)
        if name == @tag
            @tag = nil
            @found.call(@primative) if @found.nil? == false
        end
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end
