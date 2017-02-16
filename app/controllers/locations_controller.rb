class LocationsController < ApplicationController
  before_action :find_location, only: [:show, :update, :edit, :save, :watch]
  before_action :authenticate_user!, except: [:index, :map_view, :list_view, :show]

  def index
  end

  def map_view
    nearby_locations = return_nearby_locations(params['lat'], params['lng'])
    render json: nearby_locations
  end

  def list_view
    @locations = return_nearby_locations(params['lat'], params['lng'])
  end

  def show
    @saved_location = SavedLocation.find_by(user_id: current_user.id, location_id: @location.id) if current_user
    @last_updated_user = User.find(@location.last_updated_user) if @location.last_updated_user
    @API_key = Figaro.env.GOOGLE_PLACES_API_KEY
    @search_position_lat = params['lat']
    @search_position_lng = params['lng']
  end

  def mylocations
    @locations = []
    @saved_locations = SavedLocation.where(user_id: current_user.id)
    @saved_locations.each do |record|
      @locations.push(Location.find(record.location_id))
    end
  end

  def save
    saved_location = SavedLocation.find_by(user_id: current_user.id, location_id: params[:id])
    if saved_location.nil?
      SavedLocation.create(user_id: current_user.id, location_id: @location.id)
    else
      SavedLocation.delete(saved_location.id)
    end
    redirect_back(fallback_location: locations_list_view_path)
  end

  def watch
    saved_location = SavedLocation.find_by(user_id: current_user.id, location_id: params[:id])
    if saved_location.nil?
      SavedLocation.create(user_id: current_user.id, location_id: @location.id, is_watched: true)
      redirect_back(fallback_location: locations_list_view_path) && return
    end
    if saved_location.is_watched
      SavedLocation.update(saved_location.id, is_watched: false)
    else
      SavedLocation.update(saved_location.id, is_watched: true)
    end
    redirect_back(fallback_location: locations_list_view_path)
  end

  def unwatch_all
    saved_locations = SavedLocation.where(user_id: current_user.id)
    saved_locations.each do |location|
      SavedLocation.update(location.id, is_watched: false)
    end
    redirect_back(fallback_location: locations_mylocations_path)
  end

  def edit
  end

  def update
    @location.update(location_params)
    @location.last_updated_user = current_user.id
    @location.save
    notification_check(@location.id, @location.available_seats, @location.name)
    flash[:info] = 'Location info updated.'
    redirect_to @location
  end

  private

  def notification_check(id, seats, name)
    if seats > 0
      saved_locations = SavedLocation.where(location_id: id).where(is_watched: true)
      saved_locations.each do |location|
        user = User.find(location.user_id)
        # commented to prevent SMS spam
        # send_twilio(user, name)
        puts name
        puts 'twilio msg sent'
        SavedLocation.update(location.id, is_watched: false)
      end
    end
  end

  def send_twilio(user, location)
    require 'twilio-ruby'

    account_sid = Figaro.env.TWILIO_SID
    auth_token = Figaro.env.TWILIO_AUTH_TOKEN

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    @client.messages.create(
      # from assigned number from Twilio
      from: Figaro.env.TWILIO_NUMBER,
      # to receipient's phone number
      # to: '+65' + user['mobile_number'],
      # using DEV_HP due to twilio trial limitations
      to: '+65' + Figaro.env.DEV_HP,
      # input SMS msg here. NOTE: 1 SMS = 160 chars!
      body: "Hi #{user['first_name']}! Seats are now available at #{location}!"
    )
  end

  def return_nearby_locations(user_lat, user_lng)
    nearby_locations = []

    l = Location.all

    l.each do |location|
      location_hash = location.as_json
      distance = calc_distance(user_lat, user_lng, location['lat'], location['lng'])
      location_hash.store('distance', distance)
      next unless location_hash['distance'].to_f < 400
      nearby_locations.push(location_hash)
    end
    nearby_locations.sort_by! { |x| x['distance'] }
  end

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
