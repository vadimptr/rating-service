class GraphPrint
  def call(user, history, width = 1000)
    graph = Gruff::Line.new(width)
    graph.title = "User rating timeline"
    graph.theme = {
      colors: ['#3B5998'],
      marker_color: 'silver',
      font_color: '#333333',
      background_colors: ['white', 'white']
    }
    graph.data(user, history)
    graph
  end
end