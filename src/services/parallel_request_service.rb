# frozen_string_literal: true

require 'typhoeus'
require 'logger'

# service to run multiple parallel http requests
class ParallelRequestService
  def get(urls, expand: false)
    filtered_urls = urls.reject(&:empty?)
    return [] if filtered_urls.empty?

    requests = send_requests(filtered_urls)
    get_responses(requests, expand: expand)
  end

  private

  def send_requests(urls)
    hydra = Typhoeus::Hydra.new
    requests = []
    urls.each do |url|
      # TODO insert user agent from incoming request?
      # headers: {"User-Agent": useragent}
      request = Typhoeus::Request.new(url, followlocation: true)
      hydra.queue(request)
      requests.push(request)
    end
    hydra.run
    requests
  end

  def get_responses(requests, expand: false)
    responses = []
    logger = Logger.new(STDOUT)
    requests.each do |request|
      response_body = request.response.body
      response_body = '' if request.response.code != 200
      logger.error("unexpected response code " + request.response.code.to_s + " for url " + request.url)
      response = expand ? [request.url, response_body] : response_body
      responses.push(response)
    end
    responses
  end
end
