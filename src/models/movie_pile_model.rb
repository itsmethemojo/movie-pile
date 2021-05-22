# frozen_string_literal: true

require_relative '../services/movie_service.rb'

# model to retrieve movie information to show as movie pile
class MoviePileModel
  def from_textfield(textfield_data)
    movie_url_list = get_movie_url_list_from_textfield(textfield_data)
    MovieService.new.get_movies(movie_url_list)
  end

  def from_pastebin(movie_pile_id)
    movie_url_list = get_movie_url_list_from_pastebin(movie_pile_id)
    MovieService.new.get_movies(movie_url_list)
  end

  private

  def get_movie_url_list_from_textfield(textfield_data)
    textfield_data.split(/[\r\n]/)
  end

  def get_movie_url_list_from_pastebin(pastebin_id)
    pastebin_url = 'https://pastebin.com/raw/' + pastebin_id
    pastebin_raw_response = ParallelRequestService.new.get([pastebin_url]).first
    # TODO: use raise Sinatra::NotFound if pastebin is not found
    pastebin_raw_response.split(/[\r\n]/)
  end
end
