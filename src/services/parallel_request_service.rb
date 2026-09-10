# frozen_string_literal: true

require 'typhoeus'
require 'logger'

# service to run multiple parallel http requests
class ParallelRequestService
  def get(urls)
    filtered_urls = urls.reject(&:empty?)
    return [] if filtered_urls.empty?

    requests = send_requests(filtered_urls)
    get_responses(requests)
  end

  private

  def send_requests(urls)
    hydra = Typhoeus::Hydra.new
    requests = []
    urls.each do |url|
      # TODO: insert user agent from incoming request?
      # headers: {"User-Agent": useragent}
      request = Typhoeus::Request.new(get_proxy_for_url(url), followlocation: true)
      hydra.queue(request)
      requests.push(request)
    end
    hydra.run
    requests
  end

  def get_responses(requests)
    responses = []
    logger = Logger.new(STDOUT)
    requests.each do |request|
      response_body = request.response.body
      response_body = '' if request.response.code != 200
      logger.error('unexpected response code ' + request.response.code.to_s + ' for url ' + request.url)
      return_url = get_url_for_proxy(request.url)
      response = [return_url, response_body]
      responses.push(response)
    end
    responses
  end

  # TODO: move to helper class
  def get_proxy_for_url(url)
    get_replace_for_url(url, get_proxy_to_url_map)
  end

  def get_url_for_proxy(proxy)
    get_replace_for_url(proxy, get_proxy_to_url_map(true))
  end

  def get_replace_for_url(url, map)
    url_split_on_protocol = url.split('://', 2)
    return url unless url_split_on_protocol.length == 2

    url_split_on_domain = url_split_on_protocol[1].split('/', 2)
    domain = url_split_on_domain[0]
    return url unless map.key?(domain)

    url.gsub(domain, map[domain])
  end

  def get_proxy_to_url_map(reverse = false)
    mapping_list = ENV.fetch('URL_TO_PROXY_LIST', '')
    return {} if mapping_list == ''

    entries = mapping_list.split(' ')
    return_map = {}
    for entry in entries do
      key_value_split = entry.split('|')
      continue unless key_value_split.length == 2
      key = key_value_split[0]
      value = key_value_split[1]
      reverse ? return_map[value] = key : return_map[key] = value
    end
    return_map
  end
end
