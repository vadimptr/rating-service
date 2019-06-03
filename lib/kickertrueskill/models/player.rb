class Player
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: :players

    field :name, type: String
end