module GamesAdd
  def self.registered(app)
    app.post("/games/add") do
      Game.new(params).save
      [200, "OK"]
    end
  end
end