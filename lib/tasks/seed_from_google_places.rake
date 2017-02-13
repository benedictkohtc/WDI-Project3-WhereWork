task seed_from_google_places: :environment do
  require 'rubygems'
  require 'httparty' # need to gem install
  require 'json'

  API_key = ENV['GOOGLE_PLACES_API_KEY']
  # 1000 free queries per 24h, 15000 if credit card linked (no payment)
  nearbysearch_url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/'
  output_type = 'json'
  latitude = 1.3072052
  longitude = 103.831843 # this latlong is 8 Claymore Hill
  location = latitude.to_s + ',' + longitude.to_s
  radius = '400' # meters, max 50000
  type = 'cafe' # only matches one type per request,
  # multiple types per request will stop working as of 16 Feb 2017

  def add_data_to_locations_table(results)
    results.each do |result_hash|
      if Location.find_by(google_place_id: result_hash['place_id'])
        next # skip location if already in table
      end
      location = Location.new do |l|
        l.lat = result_hash['geometry']['location']['lat']
        l.lng = result_hash['geometry']['location']['lng']
        l.icon = result_hash['icon']
        l.name = result_hash['name']
        if result_hash['photos']
          l.google_photo_reference = result_hash['photos'][0]['photo_reference']
        end # saving only reference for first photo
        l.google_place_id = result_hash['place_id']
        l.google_rating = result_hash['rating']
        l.vicinity = result_hash['vicinity']
        # looks like street address but not reliable
        l.coffee = rand(2) == 1 ? true : false
        l.quiet = rand(2) == 1 ? true : false
        l.wifi = rand(2) == 1 ? true : false
        if l.wifi
          l.wifi_password = ('a'..'z').to_a.shuffle[0,8].join
        end
        l.aircon = rand(2) == 1 ? true : false
        l.total_sockets = rand(2) == 1 ? rand(10) : 0
        l.available_sockets = (l.total_sockets / 2).floor
        l.total_seats = 20 + rand(30)
        l.available_seats = (l.total_seats / 2).floor
      end
      location.save
    end
  end

  args_string = '&key=' + API_key + '&location=' + location + \
                '&radius=' + radius + '&type=' + type

  puts 'making first HTTP request to Google Places..'
  response = HTTParty.get(nearbysearch_url + output_type + '?' + args_string)
  results_first_twenty = JSON.parse(response.body)['results']
  next_page_token = JSON.parse(response.body)['next_page_token']

  puts 'adding data for first twenty locations...'
  add_data_to_locations_table(results_first_twenty)

  puts 'waiting two seconds to let next_page_token become valid...'
  sleep(2)

  puts 'making second HTTP request (second page)...'
  args_string = '&key=' + API_key + '&pagetoken=' + next_page_token
  response = HTTParty.get(nearbysearch_url + output_type + '?' + args_string)
  results_second_twenty = JSON.parse(response.body)['results']
  next_page_token = JSON.parse(response.body)['next_page_token']

  puts 'adding data for next twenty locations...'
  add_data_to_locations_table(results_second_twenty)

  puts 'waiting two seconds to let next_page_token become valid...'
  sleep(2)

  puts 'making third HTTP request (third page)...'
  args_string = '&key=' + API_key + '&pagetoken=' + next_page_token
  response = HTTParty.get(nearbysearch_url + output_type + '?' + args_string)
  results_third_twenty = JSON.parse(response.body)['results']

  puts 'adding data for next twenty locations...'
  add_data_to_locations_table(results_third_twenty)

  puts "all done (60 locations added of type #{type})."
  # puts JSON.pretty_generate(results_first_twenty)
  # puts 'RESPONSE.CODE:'
  # puts response.code
  # puts 'RESPONSE.MESSAGE:'
  # puts response.messaged
  # puts 'RESPONSE.HEADERS'
  # puts response.headers.inspect
end
