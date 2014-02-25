require 'sinatra'

## landing page
get '/' do
  haml :index
end