require 'json'

class LocationsController < ApplicationController
  def index
  end

  def secret
  end

  def twilio_test
    require 'twilio-ruby'

    account_sid = ENV['TWILIO_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    @client.messages.create(
      # from assigned number from Twilio
      from: ENV['TWILIO_NUMBER'],
      # to receipient's phone number
      to: ENV['DEV_HP'],
      # input SMS msg here. NOTE: 1 SMS = 160 chars!
      body: 'Localhost test, button test'
    )
    flash[:success] = 'Test SMS sent!'
    redirect_to action: 'secret'
  end

  # def return_nearby_locations
  #   user_location_json = { lat: 1.298993, lng: 103.828421 }
  #   # puts user_location_json
  #   user_location_json = user_location_json.to_json
  #   # puts user_location_json
  #   user_location_hash = JSON.parse(user_location_json)
  #   # puts `lat is#{user_location_hash['lat']}, lng is#{user_location_hash['lng']}`

  def return_nearby_locations(user_location_json)
    file_buffer = File.read(user_location_json)
    user_location_hash = JSON.parse(file_buffer)

    nearby_locations = {}

    l = Location.all

    l.each do |location|
      distance = calc_distance(user_location_hash['lat'], user_location_hash['lng'], location.lat, location.lng)
      # only create hash if location is nearer than 400 metres
      next unless distance < 400
      location_hash = {}
      location_hash['id'] = location.id
      location_hash['name'] = location.name
      location_hash['lat'] = location.lat
      location_hash['lng'] = location.lng
      nearby_locations[location.id] = location_hash
    end

    render json: nearby_locations
end

  private

  def calc_distance(lat1, lng1, lat2, lng2)
    lat1 = lat1.to_f
    lng1 = lng1.to_f
    lat2 = lat2.to_f
    lng2 = lng2.to_f

    rad_per_deg = Math::PI / 180    # PI / 180
    rkm = 6371                      # Earth radius in kilometers
    rm = rkm * 1000                 # Radius in meters

    dlat_rad = (lat1 - lat2) * rad_per_deg # Delta, converted to rad
    dlng_rad = (lng1 - lng2) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlng_rad / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    rm * c # Delta in meters
  end
end

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
