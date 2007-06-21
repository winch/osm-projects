
# $Id$

require 'yaml'

class Config

    def self.load(config_file)
        YAML.load(File.open(config_file))
    end

end
