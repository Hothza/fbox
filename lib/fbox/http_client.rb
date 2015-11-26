# Copyright (c) 2015, Hothza
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'net/https'
require 'cgi/cookie'

module Fbox
  class HttpClient
    attr_reader :options
    
    def initialize(options)
      @options = options
      @options.freeze
      @cookies = {}
    end

    def make_request(http_method, path, body='', headers={}, form_params = {})
      request = Net::HTTP.const_get(http_method.to_s.capitalize).new(path, headers)
      request.body = body unless body.nil?
      add_cookies(request) if options[:use_cookies]
      request.set_form_data(form_params) if !form_params.empty? && http_method.to_s.capitalize == 'Post'
      
      response = http_conn(uri).request(request)
      store_cookies(response) if options[:use_cookies]
      response
    end

    def http_conn(uri)
      if @options[:proxy_address]
          http_class = Net::HTTP::Proxy(@options[:proxy_address], @options[:proxy_port] ? @options[:proxy_port] : 80)
      else
          http_class = Net::HTTP
      end
      http_conn = http_class.new(uri.host, uri.port)
      http_conn.use_ssl = @options[:use_ssl]
      http_conn.verify_mode = @options[:ssl_verify_mode]
      http_conn
    end

    def uri
      URI.parse(@options[:site])
    end

    def request(*args)
      response = make_request(*args)
      raise HTTPError.new(response) unless response.kind_of?(Net::HTTPSuccess)
      response
    end
    
    private
      def store_cookies(response)
        cookies = response.get_fields('set-cookie')
        if cookies
          cookies.each do |cookie|
            data = CGI::Cookie.parse(cookie)
            data.delete('Path')
            @cookies.merge!(data)
          end
        end
      end

      def add_cookies(request)
        cookie_array = @cookies.values.map { |cookie| cookie.to_s }
        request.add_field('Cookie', cookie_array.join('; ')) if cookie_array.any?
        request
      end
  end
end