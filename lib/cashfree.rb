require 'uri'
require 'net/http'
require 'openssl'
require 'json'
module Cashfree
  class Cashfree    
    def initialize app_id, app_secret, app_version, cashfree_url, cashfree_return_url
      @app_id = app_id 
      @app_secret = app_secret
      @app_version = app_version
      @cashfree_url = cashfree_url
      @cashfree_return_url = cashfree_return_url
    end

    def generate_order order_id, amount, email, mobile, customer_id = nil, order_currency = "INR"
      customer_id ||= mobile.gsub("+91","")
      url = URI(@cashfree_url)
      http, request = update_request url 
      request.body = {
        "customer_details": {
          "customer_id": "#{customer_id}",
          "customer_email": "#{email}",
          "customer_phone": "#{mobile}",
        },
        "order_meta": {
          "return_url": "#{@cashfree_return_url}"
        },
        "order_id": "#{order_id}",
        "order_amount": amount,
        "order_currency": order_currency
      }.to_json
      response = http.request(request)
      return response.read_body
    end 

    def validate_payment order_id
      url = URI("#{@cashfree_url}/#{order_id}")
      http, request = update_request url 
      response = http.request(request)
      data = JSON.parse(response.read_body)
      if data["order_status"] == "PAID"
          data["order_amount"].to_f*100 
      else
          false 
      end 
    end   

    private 
      def update_request url  
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true        
        request = Net::HTTP::Post.new(url)
        request["accept"] = 'application/json'
        request["x-client-id"] = @app_id
        request["x-client-secret"] = @app_secret
        request["x-api-version"] = @app_version
        request["content-type"] = 'application/json'
        return http, request
      end 
  end 
end


#gem build cashfree.gemspec
#gem install ./cashfree-0.0.1.gem 
