# frozen_string_literal: true

require 'json'
require 'sinatra'

set :root, File.absolute_path(__dir__ + '/..')
settings_public = proc { File.join(root, 'public') }
set :public_folder, settings_public
settings_model_path = proc { File.join(root, 'src', 'models') + '/' }
set :model_path, settings_model_path
set :show_exceptions, !settings.production?
set :api_data,
    'title' => 'Movie Pile',
    'version' => '1.0.0'

get '/api/movie-pile' do
  require_relative settings.model_path + 'movie_pile_model.rb'
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileModel.new.from_textfield(
      params['data']
    )
  )
end

get '/api/movie-pile/:movie_pile_id' do
  require_relative settings.model_path + 'movie_pile_model.rb'
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileModel.new.from_pastebin(
      params['movie_pile_id']
    )
  )
end

get '/swagger.json' do
  request_data = {
    'host' => request.env['HTTP_HOST'],
    'scheme' => request.env['REQUEST_URI'].split(':').first
  }
  erb :'templates/swagger.json',
      content_type: :'application/json',
      locals: { api: request_data.merge(settings.api_data) }
end

get '/swagger-ui/index.html' do
  request_data = {
    'host' => request.env['HTTP_HOST'],
    'scheme' => request.env['REQUEST_URI'].split(':').first
  }
  erb :'templates/swagger-ui/index.html',
      locals: { api: request_data.merge(settings.api_data) }
end

get '/' do
  redirect '/swagger-ui/index.html', 302
end

not_found do
  body JSON.generate(
    status: 404,
    message: 'Not Found'
  )
end

error do
  status 500
  body JSON.generate(
    status: 500,
    message: 'Internal Server Error'
  )
end

after do
  puts body
end
