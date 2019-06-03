ENV["RACK_ENV"] = "test"

require File.expand_path("../../lib/kickertrueskill", __FILE__)

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.raise_errors_for_deprecations!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  Kernel.srand config.seed
end

