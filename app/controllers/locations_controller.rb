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

  def get_distance
    # receive user lat long in json
    # return all location lat long in json within 400 m
    # return true if result_distance < distance
    # false
  end

  def calc_distance(lat1, lon1, lat2, lon2)
    rad_per_deg = Math::PI / 180    # PI / 180
    rkm = 6371                      # Earth radius in kilometers
    rm = rkm * 1000                 # Radius in meters

    dlat_rad = (lat1 - lat2) * rad_per_deg # Delta, converted to rad
    dlon_rad = (lon1 - lon2) * rad_per_deg

    lat1_rad = lat1 * rad_per_deg
    lon1_rad = lon1 * rad_per_deg
    lat2_rad = lat2 * rad_per_deg
    lon2_rad = lon2 * rad_per_deg

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
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
