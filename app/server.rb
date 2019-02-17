# frozen_string_literal: true

require 'json'
require 'sinatra'

set :root, File.absolute_path(__dir__ + '/..')
settings_public = proc { File.join(root, 'public') }
set :public_folder, settings_public
settings_model_path = proc { File.join(root, 'src', 'models') + '/' }
settings_service_path = proc { File.join(root, 'src', 'services') + '/' }
set :model_path, settings_model_path
set :service_path, settings_service_path
set :show_exceptions, !settings.production?
set :api_data,
    'title' => 'Movie Pile',
    'version' => '0.1.0'

get '/api/movie-pile' do
  require_relative settings.model_path + 'movie_pile_model.rb'
  cache_control :public, max_age: 2_592_000
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
  cache_control :public, max_age: 2_592_000
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileModel.new.from_pastebin(
      params['movie_pile_id']
    )
  )
end

get '/share' do
  require_relative settings.service_path + 'url_encode_service.rb'
  url_encoded_data = UrlEncodeService.encode(params['data'])
  data = {
    'id' => '',
    'api_url' =>  '/api/movie-pile?data=' + url_encoded_data
  }
  erb :'templates/index.html',
      locals: { data: data }
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

get '/:movie_pile_id' do
  data = {
    'id' => params['movie_pile_id'],
    'api_url' =>  '/api/movie-pile/' + params['movie_pile_id']
  }
  erb :'templates/index.html',
      locals: { data: data }
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
  redirect '/create.html', 302
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
