module ViewsRoutes
  def self.registered(app)
    app.get "/" do
      erb :index, locals: {
        title: "Games",
        games: ::Game.all.all.sort_by {|a| a.id},
        title_ratings: "Rating",
        table_rating: ::ProcessRating.new.call
      }
    end
  end
end