# frozen_string_literal: true

require_relative '../services/parallel_request_service.rb'
require_relative '../services/html_service.rb'

# service to extract movie data from movie urls
class MovieService
  REQUIRED_MOVIE_FIELDS = %w[image title url].freeze

  def get_movies(movie_url_list)
    return [] if movie_url_list.empty?
    html_service = HtmlService.new
    movies = []
    ParallelRequestService.new.get(movie_url_list).each do |website_html|
      movie = html_service.extract_data(
        website_html, REQUIRED_MOVIE_FIELDS
      )
      movies.push(movie) if valid_movie?(movie)
    end
    movies
  end

  private

  def valid_movie?(movie)
    REQUIRED_MOVIE_FIELDS.each do |field|
      return false if movie[field] == ''
    end
    true
  end
end
