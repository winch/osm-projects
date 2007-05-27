
def create_tables(db)
    #node
    db.execute('CREATE TABLE IF NOT EXISTS node(id INTEGER PRIMARY KEY, lat NUMERIC, lon NUMERIC)')
    db.execute('CREATE TABLE IF NOT EXISTS node_tags(id NUMERIC, k TEXT, v TEXT)')
    #segment
    db.execute('CREATE TABLE IF NOT EXISTS segment(id INTEGER PRIMARY KEY, node_a NUMERIC, node_b NUMERIC)')
    db.execute('CREATE TABLE IF NOT EXISTS segment_tags(id NUMERIC, k TEXT, v TEXT)')
    #ways
    db.execute('CREATE TABLE IF NOT EXISTS way(id INTEGER, segment NUMERIC, position NUMERIC)')
    db.execute('CREATE TABLE IF NOT EXISTS way_tags(id NUMERIC, k TEXT, v TEXT)')
end