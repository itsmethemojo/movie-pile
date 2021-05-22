# frozen_string_literal: true

require 'sinatra/activerecord'
require_relative '../errors/unauthorized_error.rb'
require_relative '../orm/movie_piles.rb'
require_relative '../services/movie_service.rb'

# model to retrieve movie information to show as movie pile
class MoviePileOrmModel
  def create(data)
    movie_pile = MoviePiles.new(
      pile_id: generate_code(10),
      secret: generate_code(30),
      movie_list: []
    )
    movie_pile.name = data[:name] if data[:name]
    movie_pile.movie_list = data[:movie_list] if data[:movie_list]
    movie_pile.save
    get_response_object(movie_pile, true)
  end

  def get(movie_pile_id)
    movie_pile = MoviePiles.find_by(pile_id: movie_pile_id)
    raise Sinatra::NotFound unless movie_pile
    get_response_object(movie_pile)
  end

  def edit(movie_pile_id, secret, data)
    raise UnauthorizedError if secret.nil? || (secret == '')
    movie_pile = MoviePiles.find_by(pile_id: movie_pile_id, secret: secret)
    raise UnauthorizedError unless movie_pile
    movie_pile.name = data[:name] if data[:name]
    movie_pile.movie_list = data[:movie_list] if data[:movie_list]
    movie_pile.save
    get_response_object(movie_pile)
  end

  private

  def generate_code(length)
    charset = Array('A'..'Z') + Array('a'..'z') + Array(0..9)
    Array.new(length) { charset.sample }.join
  end

  def get_response_object(movie_pile, include_secret = false)
    # TODO: the JSON.parse can fail if there is not a valid json string in db
    response_object = {
      id: movie_pile.pile_id,
      name: movie_pile.name,
      movie_list: MovieService.new.get_movies(JSON.parse(movie_pile.movie_list))
    }
    response_object['secret'] = movie_pile.secret if include_secret
    response_object
  end
end
