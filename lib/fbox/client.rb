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

require 'json'
require 'openssl'
require 'coins_address_validator'

module Fbox
  class Client
    attr_reader :options

    DEFAULT_OPTIONS = {
      :site               => 'https://faucetbox.com',
      :context_path       => '',
      :rest_base_path     => "/api/v1/",
      :ssl_verify_mode    => OpenSSL::SSL::VERIFY_PEER,
      :use_ssl            => true,
      :api_key            => '',
    }

    FBOX_API = {
      :balance            => 'balance',
      :currencies         => 'currencies',
      :payment            => 'send',
      :payouts            => 'payouts',
    }

    @@addres_validator = nil
    
    def initialize(options={})
      @@addres_validator = CoinsAddressValidator::Validator.new
      options = DEFAULT_OPTIONS.merge(options)
      @options = options
      @options[:rest_base_path] = @options[:context_path] + @options[:rest_base_path]

      @request_client = HttpClient.new(@options)

      @options.freeze
    end
    
    def balance(currency = '')
      path = prepare_api_request(FBOX_API[:balance])
      form_params = {
        'api_key' => @options[:api_key],
        'currency' => !currency.empty? ? currency : 'BTC'
      }
      response = request(path, form_params)
      process_response(response)
    end
    
    ##
    ## Use with care it gives timeouts, probably this API call is disabled on FaucetBox
    ##
    def payouts(count = 1, currency = '')
      if count.to_i > 0 && count <= 10
        path = prepare_api_request(FBOX_API[:payouts])
        form_params = {
          'api_key' => @options[:api_key],
          'count' => count,
          'currency' => !currency.empty? ? currency : 'BTC'
        }
        response = request(path, form_params)
        process_response(response)
      else
        invalid_parameter("'count' parameter has to be in 1..10 range")
      end
    end
    
    def currencies()
      path = prepare_api_request(FBOX_API[:currencies])
      response = request(path)
      process_response(response)
    end
    
    def payment(to, amount, referral = false, currency = '')
      if !to.empty? && self.is_address_valid?(to) && amount > 0
        path = prepare_api_request(FBOX_API[:payment])
        form_params = {
          'api_key' => @options[:api_key],
          'to' => to,
          'amount' => amount,
          'currency' => !currency.empty? ? currency : 'BTC',
          'referral' => referral.to_s
        }
        response = request(path, form_params)
        process_response(response)
      else
        nil
      end
    end
    
    def is_response_ok?(body)
      body['status'].present? && body['status'] == 200
    end
    
    def is_address_valid?(address)
      @@addres_validator.is_address_valid?(address)
    end
    
    private
      def invalid_parameter(message)
        { :error => message }.to_json
      end
      
      def process_response(response)
        if response.code == '200'
          JSON.parse(response.body)
        else
          { :status => response.code.to_i, :message => response.msg.to_s }.to_json
        end
      end
      
      def prepare_api_request(api)
        @options[:site] + @options[:rest_base_path] + api
      end

      def request(path, form_params = {})
        puts "\nREQ: #{path}"
        @request_client.request(:post, path, '', default_headers(), form_params)
      end

      def default_headers()
        { 'Content-type' => 'application/x-www-form-urlencoded' }
      end
  end
end