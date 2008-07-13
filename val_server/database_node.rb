
class DatabaseNode < Database

    include Query
    include QueryNode

    def initialize(file_name)
        super(file_name)
    end

end

