https://codeship.com/projects/YOUR_PROJECT_UUID/status?branch=master

# README

## Database Setup
##### Setup Postgres  
Setup DB username (and password)

> config>database.yml

    default: &default  
        username: postgres

##### Location Seeding from Google Places
Uses HTTParty gem for making requests. Task file is in `lib\tasks\seed_from_google_places.rake`

To seed, type `rails seed_from_google_places`.

Rails DB seed file has been populated using the seed-dump gem.  
Type `rails db:seed` to use it.

## Environment Variables Setup
##### Devise Secret Keys  
These secret keys are used for verifying the integrity of signed cookies used by Devise.  
Use `rails secret` to generate your own secure secret key.

> config>secrets.yml

    development:
      secret_key_base: <insert_secure_key_here>

    test:
      secret_key_base: <insert_secure_key_here>

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

##### Figaro Gem Setup
Type `bundle exec figaro install` to create `config\application.yml` and auto add it to .gitignore.
**Note that this may create duplicate entries in .gitignore**

##### Add Twillio ENV vars to Figaro

`TWILIO_SID:` Twilio Account SID  
`TWILIO_AUTH_TOKEN:` Twilio Auth Token  
`TWILIO_NUMBER:` Assigned Twilio Number  
Note: All phone numbers need to have country codes!

> config\application.yml

    TWILIO_SID: <insert_SID>
    TWILIO_AUTH_TOKEN: <insert_tuth_token>
    TWILIO_NUMBER: <insert_twilio_number> (in single quotes!)
