require 'bundler/setup'
require 'httparty'
require 'json'

response = HTTParty.post('http://localhost:8080/products', :body => {:product => {:name => "Beer"}}.to_json, :headers => {'Content-type' => 'application/json'})
#puts response.body, response.code, response.message, response.headers.inspect

puts response.headers["location"]
puts HTTParty.get(response.headers["location"], :headers => {'Content-type' => 'application/json'})
