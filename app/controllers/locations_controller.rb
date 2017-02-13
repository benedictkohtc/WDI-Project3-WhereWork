class LocationsController < ApplicationController
  before_action :find_location, only: [:show, :update, :edit]
  before_action :authenticate_user!, only: [:update, :edit]
  def index
  end

  def secret
  end

  def show
    @last_updated_user = User.find(@location.last_updated_user) if @location.last_updated_user
    @API_key = Figaro.env.GOOGLE_PLACES_API_KEY
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

  private

  def find_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:available_seats, :available_sockets, :last_updated_user, :wifi_password)
  end
end
