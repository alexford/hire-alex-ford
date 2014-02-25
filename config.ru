require 'sass/plugin/rack'

require './hirealexford'

Sass::Plugin.options[:style] = :compressed
use Sass::Plugin::Rack

run Sinatra::Application