
def create_tables(db)
    #node
    db.execute('CREATE TABLE IF NOT EXISTS node(id NUMERIC, lat NUMERIC, lon NUMERIC)')
    db.execute('CREATE INDEX node_index on node(id)')
    db.execute('CREATE TABLE IF NOT EXISTS node_tag(id NUMERIC, k TEXT, v TEXT)')
    db.execute('CREATE INDEX node_tag_index on node_tag(id)')
    #segment
    db.execute('CREATE TABLE IF NOT EXISTS segment(id NUMERIC, node_a NUMERIC, node_b NUMERIC)')
    db.execute('CREATE INDEX segment_index on segment(id)')
    db.execute('CREATE TABLE IF NOT EXISTS segment_tag(id NUMERIC, k TEXT, v TEXT)')
    db.execute('CREATE INDEX segment_tag_index on segment_tag(id)')
    #ways
    db.execute('CREATE TABLE IF NOT EXISTS way(id INTEGER, segment NUMERIC, position NUMERIC)')
    db.execute('CREATE INDEX way_index on way(id)')
    db.execute('CREATE TABLE IF NOT EXISTS way_tag(id NUMERIC, k TEXT, v TEXT)')
    db.execute('CREATE INDEX way_tag_index on way_tag(id)')
end