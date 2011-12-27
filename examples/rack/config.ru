require "sinatra/base"

class MyApp < Sinatra::Base
  get "/" do
    "hello from rackup!"
  end
end

run MyApp
