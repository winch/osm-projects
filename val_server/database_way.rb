
class DatabaseWay < Database

    include Query
    include QueryWay

    def initialize(file_name)
        super(file_name)
    end

end

