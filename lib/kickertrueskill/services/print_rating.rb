
class PrintRating
  def call
    # пропускаем алгоритм true skill
    ps, counts = ::ProcessRating.new.call
    leagues = ::ProcessRating::LEAGUES
    
    # рисуем таблицу
    sorted = ps.sort_by { |_, v| -v.mean }
  
    grouped = {}
    leagues.each do |league, _|
      grouped[league] = sorted.select do |_, rating|
        leagues.detect { |_, range| range[0] <= rating.mean && rating.mean < range[1] }[0] == league
      end
    end

    table = Terminal::Table.new(headings: ["League", "Name", "Rating", "Games", "Deviation"]) do |t|
      grouped.each do |league, players|
        if players.size.positive?
          players.each do |player, rating|
            first_league = league if players.first[0] == player
            t.add_row([
              "#{first_league} #{leagues[first_league]}", 
              player.upcase, 
              "%+0.3f" % rating.mean, 
              counts[player], 
              "±%0.3f" % rating.deviation
            ])
          end
        else
          t.add_row ["#{league} #{leagues[league]}", " "," "," "," "]
        end
        t.add_separator unless grouped.keys.last == league
      end
    end
    table.style = { border_x: "=", border_y: "|", border_i: "x" }
    "```#{table.to_s}```"
  end
end