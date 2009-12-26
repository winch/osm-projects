
class DatabaseChangeset < Database

    include Query
    include QueryChangeset

    def initialize(file_name)
        super(file_name)
    end

end

