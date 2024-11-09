# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'sinatra/activerecord'
require_relative '../src/errors/unauthorized_error'

ActiveRecord::Base.establish_connection
require_relative '../src/orm/movie_pile_table'
MoviePileTable.migrate(:up)

set :root, File.absolute_path("#{__dir__}/..")
settings_public = proc { File.join(root, 'public') }
set :public_folder, settings_public
settings_model_path = proc { "#{File.join(root, 'src', 'models')}/" }
settings_service_path = proc { "#{File.join(root, 'src', 'services')}/" }
set :model_path, settings_model_path
set :service_path, settings_service_path
set :show_exceptions, !settings.production?
# TODO: read the version from a file generated with postinstall hook?
set :api_data,
    'title' => 'Movie Pile',
    'version' => '1.0.0'

before do
  request.body.rewind
  @request_payload = JSON.parse(request.body.read, symbolize_names: true)
rescue JSON::ParserError
  @request_payload = {}
end

get '/api/movie-pile' do
  require_relative "#{settings.model_path}movie_pile_model.rb"
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
  require_relative "#{settings.model_path}movie_pile_model.rb"
  cache_control :public, max_age: 2_592_000
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileModel.new.from_pastebin(
      params['movie_pile_id']
    )
  )
end

post '/api/v2/movie-pile/create' do
  cache_control :public, max_age: 0
  require_relative "#{settings.model_path}movie_pile_orm_model.rb"
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileOrmModel.new.create(@request_payload)
  )
end

get '/api/v2/movie-pile/:movie_pile_id' do
  cache_control :public, max_age: 0
  require_relative "#{settings.model_path}movie_pile_orm_model.rb"
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(
    MoviePileOrmModel.new.get(
      params['movie_pile_id']
    )
  )
end

post '/api/v2/movie-pile/:movie_pile_id' do
  cache_control :public, max_age: 0
  secret = request.env['HTTP_TOKEN']
  require_relative "#{settings.model_path}movie_pile_orm_model.rb"
  begin
    return_data = MoviePileOrmModel.new.edit(
      params['movie_pile_id'],
      secret,
      @request_payload
    )
  rescue UnauthorizedError
    halt(
      401,
      { 'Content-Type' => 'application/json' },
      '{"message": "not authorized"}'
    )
  end
  headers \
    'Content-Type' => 'application/json'
  body JSON.generate(return_data)
end

get '/share' do
  require_relative "#{settings.service_path}url_encode_service.rb"
  url_encoded_data = UrlEncodeService.encode(params['data'])
  data = {
    'id' => '',
    'api_url' => "/api/movie-pile?data=#{url_encoded_data}"
  }
  erb :'templates/show.html',
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
    'api_url' => "/api/movie-pile/#{params['movie_pile_id']}"
  }
  erb :'templates/show.html',
      locals: { data: data }
end

get '/v2/:movie_pile_id' do
  data = {
    'id' => params['movie_pile_id'],
    'api_url' => "/api/v2/movie-pile/#{params['movie_pile_id']}"
  }
  erb :'templates/v2/show.html',
      locals: { data: data }
end

get '/v2/:movie_pile_id/edit/:secret' do
  data = {
    'id' => params['movie_pile_id'],
    'secret' => params['secret'],
    'api_url' => "/api/v2/movie-pile/#{params['movie_pile_id']}"
  }
  erb :'templates/v2/edit.html',
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
  erb :'templates/index.html',
      locals: {}
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
