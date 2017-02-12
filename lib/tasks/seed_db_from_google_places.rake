task :seed_from_google_places do
  require 'rubygems'
  require 'httparty' # need to gem install
  require 'json'

  API_key = 'AIzaSyCm9k1ny7YRfy9IVPQbrtaFQayu70QaScg'.freeze
  # 1000 free queries per 24h, 15000 if credit card linked (no payment)
  nearbysearch_url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/'
  output_type = 'json'
  latitude = 1.352673
  longitude = 103.808791 # this latlong is middle of reservoir park
  location = latitude.to_s + ',' + longitude.to_s
  radius = '50000' # meters, max 50000
  type = 'cafe' # only matches one type per request,
  # multiple types per request will stop working as of 16 Feb 2017

  # response = HTTParty.get('https://maps.googleapis.com/maps/api/place/nearbysearch/')

  args_string = '&key=' + API_key + '&location=' + location + \
                '&radius=' + radius + '&type=' + type

  puts 'Request:   ' + nearbysearch_url + output_type + '?' + args_string

  response = HTTParty.get(nearbysearch_url + output_type + '?' + args_string)

  puts 'RESPONSE.BODY:'
  puts JSON.pretty_generate(JSON.parse(response.body)['results'][1])
  # puts 'RESPONSE.CODE:'
  # puts response.code
  # puts 'RESPONSE.MESSAGE:'
  # puts response.messaged
  # puts 'RESPONSE.HEADERS'
  # puts response.headers.inspect
end
