class LocationsController < ApplicationController
  before_action :find_location, only: [:show, :update, :edit, :save]
  before_action :authenticate_user!, only: [:update, :edit, :secret, :twilio_test, :mylocations]

  def index
  end

  def list
    @locations = Location.limit(10)
  end

  def secret
  end

  def mylocations
    @locations = []
    saved_location_ids = SavedLocation.where(user_id: current_user.id)
    saved_location_ids.each do |id|
      @locations.push(Location.find(id))
    end
  end

  def show
    @saved_location = SavedLocation.find_by(user_id: current_user.id, location_id: @location.id)
    @last_updated_user = User.find(@location.last_updated_user) if @location.last_updated_user
    @API_key = Figaro.env.GOOGLE_PLACES_API_KEY
  end

  def save
    saved_location = SavedLocation.find_by(user_id: current_user.id, location_id: @location.id)
    if saved_location == nil
      SavedLocation.create({:user_id => current_user.id, :location_id => @location.id})
    else
      SavedLocation.delete(saved_location.id)
    end
    redirect_back(fallback_location: locations_list_path)
  end

  def edit
  end

  def update
    @location.update(location_params)
    @location.last_updated_user = current_user.id
    @location.save
    flash[:info] = 'Location info updated.'
    redirect_to @location
  end

  def twilio_test
    require 'twilio-ruby'

    account_sid = Figaro.env.TWILIO_SID
    auth_token = Figaro.env.TWILIO_AUTH_TOKEN

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    @client.messages.create(
      # from assigned number from Twilio
      from: Figaro.env.TWILIO_NUMBER,
      # to receipient's phone number
      to: Figaro.env.DEV_HP,
      # input SMS msg here. NOTE: 1 SMS = 160 chars!
      body: 'Localhost test, figaro test'
    )
    flash[:success] = 'Test SMS sent!'
    redirect_to action: 'secret'
  end

  def return_nearby_locations
    nearby_locations = []

    l = Location.all

    l.each do |location|
      distance = calc_distance(params['lat'], params['lng'], location.lat, location.lng)
      # only create hash if location is nearer than 400 metres
      next unless distance < 400
      location_hash = {}
      location_hash['id'] = location.id
      location_hash['name'] = location.name
      location_hash['lat'] = location.lat
      location_hash['lng'] = location.lng
      location_hash['distance'] = distance
      nearby_locations.push(location_hash)
    end

    nearby_locations.sort_by! { |x| x['distance'] }
    render json: nearby_locations
  end

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:available_seats, :available_sockets, :last_updated_user, :wifi_password)
  end

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
