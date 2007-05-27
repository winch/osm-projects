
class Listener

    def tag_start(name, attrs)
        #puts name
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end