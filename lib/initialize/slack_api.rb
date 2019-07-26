Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

class SlackApi
  class_attribute :users

  class << self
    def open_dialog_new_match(trigger_id)
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
              "data_source": "users"
            },
            {
              "label":   "Team 1 Player 2",
              "name":    "player2",
              "type":    "select",
              "data_source": "users"
            },
            {
              "label":   "Team 2 Player 1",
              "name":    "player3",
              "type":    "select",
              "data_source": "users"
            },
            {
              "label":   "Team 2 Player 2",
              "name":    "player4",
              "type":    "select",
              "data_source": "users"
            },
            {
              "label":   "Scores",
              "name":    "teamScores",
              "type":    "text",
              "placeholder": "8:8 8:7 8:4"
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
          "title": "Request add new player",
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
        # as_user: false,
        # username: "Kicker bot"
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
        request.headers["Authorization"] = "Bearer #{ENV["SLACK_TOKEN"]}"
        request.options.timeout = 60
        request.options.open_timeout = 60
      end

      JSON.parse response.body
    end

    def user_list
      return @users if @users
      @users = {}
      puts "Fetch user list..."
      list = make_request(:get, "users.list")["members"]
      puts "Recieved users. Count: #{list.size}"
      list.each do |u|
        @users[u["id"]] = u["profile"]["real_name"].downcase.sub(" ", "_")
      end
      @users
    rescue => ex
      puts ex.message
      raise ex
    end

    def upload_file(channel, title, file_path)
      body = {
        file: Faraday::UploadIO.new(file_path, "image/png"),
        token: ENV["SLACK_TOKEN"],
        channels: channel,
        filename: "plot.png"
      }
      make_request(:post, "files.upload", body.to_json)
    rescue => ex
      puts ex.message
      raise ex
    end
  end
end
