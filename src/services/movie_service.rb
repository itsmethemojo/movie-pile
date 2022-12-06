# frozen_string_literal: true

require 'filecache'

require_relative '../services/parallel_request_service'
require_relative '../services/html_service'

# service to extract movie data from movie urls
class MovieService
  REQUIRED_MOVIE_FIELDS = %w[image title url].freeze

  def initialize
    cache_path = ENV.fetch('CACHE_PATH', '/tmp/caches')
    @cache = FileCache.new('movies-cache', cache_path)
    @html_service = HtmlService.new
    @request_service = ParallelRequestService.new
  end

  def get_movies(movie_url_list)
    return [] if movie_url_list.empty?

    cached_movies = movies_from_cache(movie_url_list)
    loaded_movies = movies_from_url(movie_url_list - cached_movies.keys)
    write_movie_cache(loaded_movies)

    cached_movies.values + loaded_movies.values
  end

  private

  def movies_from_cache(movie_url_list)
    cached_movies = {}
    movie_url_list.each do |movie_url|
      cached_movie = @cache.get(movie_url)
      next if cached_movie.nil?

      cached_movies[movie_url] = cached_movie
    end

    cached_movies
  end

  def movies_from_url(movie_url_list)
    loaded_movies = {}
    @request_service.get(movie_url_list, expand: true).each do |response|
      url, website_html = response
      movie = @html_service.extract_data(
        website_html, REQUIRED_MOVIE_FIELDS
      )
      loaded_movies[url] = movie if valid_movie?(movie)
    end
    loaded_movies
  end

  def write_movie_cache(loaded_movies)
    loaded_movies.each do |url, movie|
      @cache.set(url, movie)
    end
  end

  def valid_movie?(movie)
    REQUIRED_MOVIE_FIELDS.each do |field|
      return false if movie[field] == ''
    end
    true
  end
end
