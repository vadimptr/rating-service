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