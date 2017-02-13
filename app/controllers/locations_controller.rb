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
end