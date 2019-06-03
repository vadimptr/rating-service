class SlackApi
  class << self
    def users_list
      ::Player.find({}).limit(100).map do |player|
        {
          "label": player.name,
          "value": player.name
        }
      end
    end

    def open_dialog_new_match(trigger_id, users)
      scores = (0..8).map do |number|
        {
          "label": number,
          "value": number
        }
      end

      result = {
        "trigger_id": trigger_id,
        "dialog": {
          "callback_id": "match-dialog",
          "title": "Request to add match",
          "submit_label": "Request",
          "notify_on_cancel": false,
          "state": "Limo",
          "elements": [
            {
              "label":   "Team 1 Player 1",
              "name":    "player1",
              "type":    "select",
              "options": users,
            },
            {
              "label":   "Team 1 Player 2",
              "name":    "player2",
              "type":    "select",
              "options": users,
            },
            {
              "label":   "Team 1 Scores",
              "name":    "team1scores",
              "type":    "select",
              "options": scores,
            },
            {
              "label":   "Team 2 Scores",
              "name":    "team2scores",
              "type":    "select",
              "options": scores,
            },
            {
              "label":   "Team 2 Player 1",
              "name":    "player3",
              "type":    "select",
              "options": users,
            },
            {
              "label":   "Team 2 Player 2",
              "name":    "player4",
              "type":    "select",
              "options": users,
            }
          ]
        }
      }
      make_request(:post, "dialog.open", result.to_json)
    end

    def open_dialog_new_player(trigger_id)
      result = {
        "trigger_id": trigger_id,
        "dialog": {
          "callback_id": "new-player-dialog",
          "title": "Request to add new player",
          "submit_label": "Request",
          "notify_on_cancel": false,
          "state": "Limo",
          "elements": [
            {
              "label":   "New player name",
              "name":    "new_player",
              "type":    "text",
              "placeholder": "new player",
              "max_length": 100,
              "min_length": 5
            }
          ]
        }
      }
      make_request(:post, "dialog.open", result.to_json)
    end

    def post_message(channel, message)
      body = {
        channel: channel,
        text: message,
        as_user: false,
        username: "Kicker bot"
      }
      make_request(:post, "chat.postMessage", body.to_json)
    end

    def make_request(method, operation, body = nil)
      connection = Faraday.new(url: "https://slack.com/api/#{operation}") do |conn|
        conn.adapter Faraday.default_adapter
      end

      response = connection.send(method) do |request|
        request.body = body if body
        request.headers["Content-Type"] = "application/json"
        request.headers["Authorization"] = "Bearer xoxp-11055979686-125038469269-641658039924-a0681bb3b43306d453b1a7b995aadbc7"
        request.options.timeout = 60
        request.options.open_timeout = 60
      end

      JSON.parse response.body
    end
  end
end
