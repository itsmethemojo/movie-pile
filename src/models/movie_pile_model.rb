# frozen_string_literal: true

require 'json'
require 'typhoeus'
require 'nokogiri'

# model to retrieve movie information to show as movie pile
class MoviePileModel
  def from_textfield(textfield_data)
    movie_url_list = get_movie_urls_from_textfield(textfield_data)
    get_movies(movie_url_list)
  end

  def from_pastebin(movie_pile_id)
    movie_url_list = get_movie_urls_from_pastebin(movie_pile_id)
    get_movies(movie_url_list)
  end

  private

  def get_movie_urls_from_textfield(_textfield_data)
    urls = []
    # TODO: implement
    urls
  end

  def get_movie_urls_from_pastebin(pastebin_id)
    pastebin_response = Typhoeus::Request.new(
      'https://pastebin.com/raw/' + pastebin_id,
      followlocation: true
    ).run
    pastebin_response.body.split(/[\r\n]/)
  end

  def get_movies(movie_url_list)
    hydra = Typhoeus::Hydra.new
    movie_requests = []
    movie_url_list.each do |movie_url|
      request = Typhoeus::Request.new(movie_url, followlocation: true)
      hydra.queue(request)
      movie_requests.push(request)
    end
    hydra.run
    extract_movies_from_movie_requests(movie_requests)
  end

  def extract_movies_from_movie_requests(movie_requests)
    movies = []
    movie_requests.each do |movie_request|
      html_doc = Nokogiri::HTML(movie_request.response.body)
      movie = {
        'title' => extract_meta_property_from_html(html_doc, 'og:title'),
        'image' => extract_meta_property_from_html(html_doc, 'og:image')
      }
      movies.push(movie) if valid_movie?(movie)
    end
    movies
  end

  def extract_meta_property_from_html(html_doc, property_name)
    property = ''
    html_doc.css('meta[property="' + property_name + '"]').each do |element|
      property = element['content']
      break
    end
    property
  end

  def valid_movie?(movie)
    movie.key?('title') &&
      movie.key?('image') &&
      movie['title'] != '' &&
      movie['image'] != ''
  end
end
