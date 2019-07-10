class ProcessRating
  include Saulabs::TrueSkill

  DEFAULT_MEAN = 0
  DEFAULT_DEVIATION = 8

  def call(kind = "normal")
    players = {}
    counts = {}
    Game.all.sort_by(&:id).each do |game|
      p1 = game.player1
      p2 = game.player2
      score1, score2 = process_scores(game.score1, game.score2, kind)
      p3 = game.player3
      p4 = game.player4

      init_player(players, counts, p1, p2, p3, p4)
  
      team1 = []
      team1 << players[p1] if p1
      team1 << players[p2] if p2
  
      team2 = []
      team2 << players[p3] if p3
      team2 << players[p4] if p4
  
      ScoreBasedBayesianRating.new(team1 => score1, team2 => score2).update_skills
  
      players[p1] = team1[0] if p1
      players[p2] = team1[1] if p2
      players[p3] = team2[0] if p3
      players[p4] = team2[1] if p4

      yield(players[p1], players[p2], players[p3], players[p4]) if block_given?
    end
    [players, counts]
  end

  private

  def process_scores(s1, s2, kind)
    case kind
    when "only_win"
      [s1 > s2 ? 1 : 0, s2 > s1 ? 1 : 0]
    when "special"
      [s1 > s2 ? 10 : -10, s2 > s1 ? 10 : -10]
    when "normal"
      [s1, s2]
    else
      [s1, s2]
    end
  end

  def init_player(players, counts, *ps)
    ps.compact.each do |p|
      players[p] = Rating.new(DEFAULT_MEAN, DEFAULT_DEVIATION) unless players.include?(p)
      counts[p] ||= 0
      counts[p] += 1
    end
  end
end
