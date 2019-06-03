require "sinatra/base"

class WebApplication < Sinatra::Base
  register HelperRoutes
  register GamesAdd
  register ViewsRoutes
  register SlackRoutes

  configure do
    disable :session, :show_exceptions, :dump_errors
    use Rack::Parser, content_types: { "application/json" => ->(body) { JSON.decode(body) } }
  end

  error do
    e = request.env["sinatra.error"]
    response = {}
    response["status"] = "fail"
    response["exception"] = e.exception
    response["message"] = e.message
    response["backtrace"] = e.backtrace
    response.to_json
  end
end