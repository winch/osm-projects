
# $Id$

module Database

    def Database.create_tables(db)
        #node
        db.execute('CREATE TABLE node(id NUMERIC, lat NUMERIC, lon NUMERIC)')
        db.execute('CREATE TABLE node_tag(id NUMERIC, k TEXT, v TEXT)')
        #segment
        db.execute('CREATE TABLE segment(id NUMERIC, node_a NUMERIC, node_b NUMERIC)')
        db.execute('CREATE TABLE segment_tag(id NUMERIC, k TEXT, v TEXT)')
        #ways
        db.execute('CREATE TABLE way(id INTEGER, segment NUMERIC, position NUMERIC)')
        db.execute('CREATE TABLE way_tag(id NUMERIC, k TEXT, v TEXT)')
    end
    
     def Database.create_index(db)
        #node
        db.execute('CREATE INDEX node_index on node(id)')
        db.execute('CREATE INDEX node_tag_index on node_tag(id)')
        #segment
        db.execute('CREATE INDEX segment_index on segment(id)')
        db.execute('CREATE INDEX segment_tag_index on segment_tag(id)')
        #way
        db.execute('CREATE INDEX way_index on way(id)')
        db.execute('CREATE INDEX way_tag_index on way_tag(id)')
    end

end