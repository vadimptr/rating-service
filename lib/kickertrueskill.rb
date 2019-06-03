env = ENV["RACK_ENV"] || "development"

# require gems
require "bundler"
Bundler.require(:default, env.to_sym)

# require copied libs
require_all "lib/saulabs"
require_all "lib/terminal-table-master"

# require all another
require_all "lib/initialize"

# require all another
require_all "lib/kickertrueskill"

