
class DatabaseMap < Database

    include Query
    include QueryNode
    include QueryWay

    def initialize(file_name)
        super(file_name)
    end

end

