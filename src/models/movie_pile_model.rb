# frozen_string_literal: true

require_relative '../services/parallel_request_service.rb'
require_relative '../services/html_service.rb'

# model to retrieve movie information to show as movie pile
class MoviePileModel
  REQUIRED_MOVIE_FIELDS = %w[image title url].freeze

  def from_textfield(textfield_data)
    movie_url_list = get_movie_urls_from_textfield(textfield_data)
    get_movies(movie_url_list)
  end

  def from_pastebin(movie_pile_id)
    movie_url_list = get_movie_url_list_from_pastebin(movie_pile_id)
    get_movies(movie_url_list)
  end

  private

  def get_movie_url_list_from_textfield(_textfield_data)
    list = []
    list
  end

  def get_movie_url_list_from_pastebin(pastebin_id)
    pastebin_url = 'https://pastebin.com/raw/' + pastebin_id
    pastebin_raw_response = ParallelRequestService.new.get([pastebin_url]).first
    pastebin_raw_response.split(/[\r\n]/)
  end

  def get_movies(movie_url_list)
    html_service = HtmlService.new
    website_htmls = ParallelRequestService.new.get(movie_url_list)
    movies = []
    website_htmls.each do |website_html|
      movie = html_service.extract_data(
        website_html, REQUIRED_MOVIE_FIELDS
      )
      movies.push(movie) if valid_movie?(movie)
    end
    movies
  end

  def valid_movie?(movie)
    REQUIRED_MOVIE_FIELDS.each do |field|
      return false if movie[field] == ''
    end
    true
  end
end
