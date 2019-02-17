# frozen_string_literal: true

require 'erb'

# service to url_encode strings
class UrlEncodeService
  def self.encode(string)
    ERB::Util.url_encode(string)
  end
end
