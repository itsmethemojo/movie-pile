# frozen_string_literal: true

require 'nokogiri'

# service to extract semantic data from html documents
class HtmlService
  SEARCH_DEFINITIONS = {
    'image' => {
      'css_query' => 'meta[property="og:image"]',
      'attribute_name' => 'content'
    },
    'title' => {
      'css_query' => 'meta[property="og:title"]',
      'attribute_name' => 'content'
    },
    'url' => {
      'css_query' => 'link[rel="canonical"]',
      'attribute_name' => 'href'
    }
  }.freeze

  DEFINITION_MISSING = 'missing search definition for required field'

  def extract_data(movie_website_html, required_fields)
    html_doc = Nokogiri::HTML(movie_website_html)
    movie = {}
    required_fields.each do |field|
      raise DEFINITION_MISSING unless SEARCH_DEFINITIONS.key?(field)

      movie[field] = extract_attribute_with_search_defintion(html_doc, field)
    end
    movie
  end

  private

  def extract_attribute_with_search_defintion(html_doc, search_defintion)
    extract_attribute_from_html_element(
      html_doc,
      SEARCH_DEFINITIONS[search_defintion]['css_query'],
      SEARCH_DEFINITIONS[search_defintion]['attribute_name']
    )
  end

  def extract_attribute_from_html_element(html_doc, css_query, attribute_name)
    attribute_value = ''
    # rubocop:disable Lint/UnreachableLoop
    html_doc.css(css_query).each do |element|
      # rubocop:enable Lint/UnreachableLoop
      attribute_value = element[attribute_name]
      break
    end
    attribute_value
  end
end
