
ENV["MONGODB_URI"] ||= "mongodb://heroku_m80znbsg:3oms87rot8pqjq814g3r5il1g7@ds245715.mlab.com:45715/heroku_m80znbsg"

uri = Mongo::URI.new(ENV["MONGODB_URI"])
configuration = {
  clients: {
    default: {
      database: uri.database,
      hosts: uri.servers,
      options: uri.client_options
    }
  }
}

Mongoid::Config.load_configuration(configuration)
Mongoid.raise_not_found_error = false