module SlackRoutes
  def self.registered(app)
    app.post("/match") do
      puts JSON.pretty_generate params
      if params["payload"]
        payload = JSON.parse(params["payload"])
        channel = payload["channel"]["id"]
        submission = payload["submission"]

        player1 = submission["player1"]
        player2 = submission["player2"]
        score1 = submission["team1scores"].to_i
        score2 = submission["team2scores"].to_i
        player3 = submission["player3"]
        player4 = submission["player4"]

        puts JSON.pretty_generate submission

        # добавляем запись
        Game.new(
          player1: player1,
          player2: player2,
          player3: player3,
          player4: player4,
          score1: score1,
          score2: score2
        ).save
        
        table_raw = ::PrintRating.new.call

        # публикуем сообщение с таблицей
        body = SlackApi.post_message(channel, table_raw)
        puts JSON.pretty_generate body
        [200, ""]
      else
        # открываем диалог
        users = SlackApi.users_list
        body = SlackApi.open_dialog_new_match(params["trigger_id"], users)
        puts JSON.pretty_generate body
        [200, ""]
      end
    end

    app.post("/table") do
      puts JSON.pretty_generate params
      table_raw = ::PrintRating.new.call
      body = SlackApi.post_message(params["channel_id"], table_raw)
      puts JSON.pretty_generate body
      [200, ""]
    end

    app.post("/new_player") do
      puts JSON.pretty_generate params
      if params["payload"]
        payload = JSON.parse(params["payload"])
        channel = payload["channel"]["id"]
        submission = payload["submission"]

        new_player = submission["new_player"]

        player = ::Player.find_by({name: new_player}) rescue nil
        if player
          return [200, "Player '#{new_player}' already registred"]
        end
        
        body = SlackApi.post_message(channel, "New player '#{new_player}' registered")
        puts JSON.pretty_generate body
        [200, ""]
      else
        # открываем диалог
        body = SlackApi.open_dialog_new_player(params["trigger_id"])
        puts JSON.pretty_generate body
        [200, ""]
      end
    end
  end
end