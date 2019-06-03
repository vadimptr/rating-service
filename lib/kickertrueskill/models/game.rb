class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: :games

  field :player1, type: String
  field :player2, type: String
  field :player3, type: String
  field :player4, type: String
  field :score1, type: Integer
  field :score2, type: Integer
end