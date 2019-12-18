module SlackRoutes
  def self.registered(app)
    app.post("/match") do
      puts JSON.pretty_generate params
      if params["payload"]
        payload = JSON.parse(params["payload"])
        channel = payload["channel"]["id"]
        user_id = payload["user"]["id"]
        submission = payload["submission"]

        puts JSON.pretty_generate submission

        user_list = SlackApi.user_list

        player1 = user_list[submission["player1"]]
        player2 = user_list[submission["player2"]]
        player3 = user_list[submission["player3"]]
        player4 = user_list[submission["player4"]]
        teamScores = submission["teamScores"]

        return if player1.nil? || player2.nil? || player3.nil? || player4.nil? || teamScores.nil?
       
        diffs = {
          player1 => [],
          player2 => [],
          player3 => [],
          player4 => [],
        }

        # rating before
        players, counts = ProcessRating.new.call
        diffs[player1] << "%+0.3f" % (players[player1]&.mean || 0)
        diffs[player2] << "%+0.3f" % (players[player2]&.mean || 0)
        diffs[player3] << "%+0.3f" % (players[player3]&.mean || 0)
        diffs[player4] << "%+0.3f" % (players[player4]&.mean || 0)

        headings = ["Player", "Score before"]
        groups = teamScores.scan(/([0-8]:[0-8])+/).flatten
        groups.each do |group|
          scores = group.scan(/([0-8]):([0-8])/).flatten
          score1 = scores[0]
          score2 = scores[1]
          headings << group

          # добавляем запись
          Game.new(
            player1: player1,
            player2: player2,
            player3: player3,
            player4: player4,
            score1: score1,
            score2: score2
          ).save

          players, counts = ProcessRating.new.call

          # rating after
          diffs[player1] << "%+0.3f" %  players[player1].mean 
          diffs[player2] << "%+0.3f" %  players[player2].mean
          diffs[player3] << "%+0.3f" %  players[player3].mean
          diffs[player4] << "%+0.3f" %  players[player4].mean

          puts "Add game: #{player1} #{player2} #{score1} : #{score2} #{player3} #{player4}"
        end

        puts "Games added."
        
        #Current Deviation to the second position in view table
        headings << "Deviation"
        diffs[player1] << "%+0.3f" % (players[player1]&.deviation || 0))
        diffs[player2] << "%+0.3f" % (players[player2]&.deviation || 0))
        diffs[player3] << "%+0.3f" % (players[player3]&.deviation || 0))
        diffs[player4] << "%+0.3f" % (players[player4]&.deviation || 0))

        # print table
        # table_raw = PrintRating.new.call(players, counts)

        table = Terminal::Table.new(headings: headings) do |t|
          diffs.each do |player, history|
            t.add_row [player] + history
          end
        end

        user = user_list[user_id]

        # публикуем сообщение с таблицей
        body = SlackApi.post_message(channel, "```User: #{user} \n#{table}```")

        puts "Message with table posted."
       
        [200, ""]
      else
        # открываем диалог
        SlackApi.open_dialog_new_match(params["trigger_id"])
        [200, ""]
      end
    rescue => ex
      puts ex.message
      [500, ex.message]
    end

    app.post("/table") do
      puts JSON.pretty_generate params
      players, counts = ProcessRating.new.call(params["text"])
      user_list = SlackApi.user_list
      user = user_list[params["user_id"]]
      table = PrintRating.new.call(players, counts)
      body = SlackApi.post_message(params["channel_id"], "```User: #{user}\n#{table}```")
      #puts JSON.pretty_generate body
      [200, ""]
    rescue => ex
      puts ex.message
      puts ex.backtrace
      [500, ex.message]
    end

    app.post("/plot") do
      puts JSON.pretty_generate params

      user_id = params["user_id"]
      channel_id = params["channel_id"]

      user_list = SlackApi.user_list
      user = user_list[user_id]

      history = []
      ProcessRating.new.call do |players_hash|
        exist = players_hash[user]
        if exist
          history << exist.mean
        end
      end

      graph = GraphPrint.new.call(user, history)
      file_name = "file_#{graph.object_id}.png"
      File.write(file_name, graph.to_blob)

      client = Slack::Web::Client.new
      client.files_upload(
        channels: channel_id,
        as_user: true,
        file: Faraday::UploadIO.new(file_name, 'image/png'),
        title: "Rating graph",
        filename: file_name,
        token: ENV["SLACK_TOKEN"]
      )
      
      File.delete(file_name) if file_name && File.exist?(file_name)

      [200, ""]
    rescue => ex
      File.delete(file_name) if file_name && File.exist?(file_name)

      puts ex.message
      puts ex.backtrace
      [500, ex.message]
    end
  end
end
