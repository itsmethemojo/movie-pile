# frozen_string_literal: true

require 'typhoeus'

# service to run multiple parallel http requests
class ParallelRequestService
  def get(urls)
    filtered_urls = urls.reject(&:empty?)
    requests = send_requests(filtered_urls) unless filtered_urls.empty?
    get_responses(requests)
  end

  private

  def send_requests(urls)
    hydra = Typhoeus::Hydra.new
    requests = []
    urls.each do |url|
      request = Typhoeus::Request.new(url, followlocation: true)
      hydra.queue(request)
      requests.push(request)
    end
    hydra.run
    requests
  end

  def get_responses(requests)
    responses = []
    requests.each do |request|
      response_body = request.response.body
      response_body = '' if request.response.code != 200
      responses.push(response_body)
    end
    responses
  end
end
