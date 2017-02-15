# normally, use rails db:seed instead of running this task,
# this task is only for getting new data from Google Places from scratch.

# populates locations from Google Places
# makes random values for some fields
# will get photos and upload them to Cloudinary also,
# so you need valid Cloudinary account data in config/cloudinary.yml

# run "rails add_opening_times" after this task to add opening times to all locations

task seed_from_google_places: :environment do
  require 'rubygems'
  require 'httparty' # need to gem install
  require 'json'

  @API_key = ENV['GOOGLE_PLACES_API_KEY']

  # for getting 60 locations from Google Places
  @nearbysearch_url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/'
  @output_type = 'json'
  startlat = 1.2984459
  startlong = 103.825591
  endlat = 1.308294
  endlong = 103.847305 # roughly the length of Orchard Roads
  # 1.1km north to south
  # 2.5km west to east
  longstep = 0.002814
  latstep = 0.00246
  # latitude = 1.3072052
  # longitude = 103.831843 # this latlong is 8 Claymore Hill
  @radius = '400' # meters, max 50000
  @type = 'cafe' # only matches one type per request,

  # for getting photo from Google Places Photos
  @places_photo_url = 'https://maps.googleapis.com/maps/api/place/photo'
  @maxheight = '800'
  @maxwidth = '800'



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
        if result_hash['photos'] # saving only reference for first photo
          l.google_photo_reference = result_hash['photos'][0]['photo_reference']
          photo_args_string = 'key=' + @API_key + \
                              '&photoreference=' + l.google_photo_reference + \
                              '&maxheight=' + @maxheight + '&maxwidth=' + @maxwidth
          response = HTTParty.get(@places_photo_url + '?' + photo_args_string)
          File.open("#{result_hash['place_id']}.jpg", 'wb') do |f|
            f.write response.body
          end
          cloudinary_response = Cloudinary::Uploader.upload("#{result_hash['place_id']}.jpg")
          puts "uploading image #{result_hash['place_id']} to cloudinary"
          l.cloudinary_link = cloudinary_response['secure_url']
          File.delete("#{result_hash['place_id']}.jpg")
        end
        l.google_place_id = result_hash['place_id']
        l.google_rating = result_hash['rating']
        l.vicinity = result_hash['vicinity']
        # looks like street address but not reliable
        l.coffee = rand(2) == 1 ? true : false
        l.quiet = rand(2) == 1 ? true : false
        l.wifi = rand(2) == 1 ? true : false
        l.wifi_name = l.name.squish.downcase.tr(' ', '_')[0..12] + rand(9).to_s + rand(9).to_s if l.wifi
        l.wifi_password = ('a'..'z').to_a.sample(8).join if l.wifi
        l.aircon = rand(2) == 1 ? true : false
        l.total_sockets = rand(2) == 1 ? rand(10) : 0
        l.available_sockets = (l.total_sockets / 2).floor
        l.total_seats = 20 + rand(30)
        l.available_seats = rand(20)
      end
      location.save
    end
  end

  def add_location(latitude, longitude)
    location = latitude.to_s + ',' + longitude.to_s

    puts('requesting from Google Places at location ' + location)

    args_string = '&key=' + @API_key + '&location=' + location + \
                  '&radius=' + @radius + '&type=' + @type

    puts 'making first HTTP request to Google Places..'
    response = HTTParty.get(@nearbysearch_url + @output_type + '?' + args_string)
    results_first_twenty = JSON.parse(response.body)['results']
    next_page_token = JSON.parse(response.body)['next_page_token']

    return if results_first_twenty == nil
    return if next_page_token == nil

    puts 'adding data for first twenty locations...'
    add_data_to_locations_table(results_first_twenty)

    puts 'waiting two seconds to let next_page_token become valid...'
    sleep(2)

    puts 'making second HTTP request (second page)...'
    args_string = '&key=' + @API_key + '&pagetoken=' + next_page_token
    response = HTTParty.get(@nearbysearch_url + @output_type + '?' + args_string)
    results_second_twenty = JSON.parse(response.body)['results']
    next_page_token = JSON.parse(response.body)['next_page_token']

    return if results_second_twenty == nil
    return if next_page_token == nil

    puts 'adding data for next twenty locations...'
    add_data_to_locations_table(results_second_twenty)

    puts 'waiting two seconds to let next_page_token become valid...'
    sleep(2)

    puts 'making third HTTP request (third page)...'
    args_string = '&key=' + @API_key + '&pagetoken=' + next_page_token
    response = HTTParty.get(@nearbysearch_url + @output_type + '?' + args_string)
    results_third_twenty = JSON.parse(response.body)['results']

    return if results_third_twenty == nil

    puts 'adding data for next twenty locations...'
    add_data_to_locations_table(results_third_twenty)

    puts "all done for latlong pair."
  end

  (startlat..endlat).step(latstep) do |lat|
    (startlong..endlong).step(longstep) do |long|
      add_location(lat,long)
    end
  end
end
