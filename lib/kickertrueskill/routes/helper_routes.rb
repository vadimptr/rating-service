module HelperRoutes
  def self.registered(app)
    app.get("/ping") do
      [200, PrintRating.new.call]
    end
  end
end