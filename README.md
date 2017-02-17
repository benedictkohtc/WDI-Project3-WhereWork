[ ![Codeship Status for benedictkohtc/WDI-Project3-WhereWork](https://app.codeship.com/projects/3e284e50-d555-0134-2621-0eb6a9a7540b/status?branch=master)](https://app.codeship.com/projects/202447)

# wherework

This version of our app shows you the nearest places to work within 400 metres of your current location. Users can toggle filters such as the availability of seats, wi-fi, coffee, power sockets, etc. Users can also search for places around another location.

![alt tag](http://i.giphy.com/Qdtg9bHZzC9dm.gif)

![alt tag](http://i.giphy.com/QgMiSknizH1f2.gif)

# Getting Started

## Database Setup
##### Setup Postgres  
Setup DB username (and password)

> config>database.yml

    default: &default  
        username: postgres

##### Location Seeding from Google Places
Uses HTTParty gem for making requests. Task file is in `lib\tasks\seed_from_google_places.rake`

To seed, type `rails seed_from_google_places`. and then 'rails add_opening_times'. You will need a Cloudinary account with your cloudinary.yml in /config. To clear all Cloudinary images from your account (warning will delete ALL your images), run 'rails delete_all_cloudinary_images'.

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

## How to Use

See the places to work around your current location displayed on the Google Map, or those around another location you can search for in the search bar. Toggle the various filters to refine your search.

## Tests?



## Live Version

The app is available [here](https://wherework.herokuapp.com/).

## Built With

* [Ruby on Rails](http://rubyonrails.org/)
* [PostgreSQL](https://www.postgresql.org/)
* [Devise](https://github.com/plataformatec/devise)
* [Seed_dump](https://github.com/rroblak/seed_dump)
* [Cloudinary](http://cloudinary.com/)
* [Google Maps API](https://developers.google.com/maps/)
* [Google Places API](https://developers.google.com/places/)
* [HTTParty](https://github.com/jnunemaker/httparty)
* [Clipboard](https://github.com/sadiqmmm/clipboard-rails)
* [Figaro](https://github.com/laserlemon/figaro)
* [Twilio](https://www.twilio.com/blog/2014/02/twilio-on-rails-integrating-twilio-with-your-rails-4-app.html)

## Workflow

* [User research](https://keith152.typeform.com/report/VPGkHU/q6Mh)
* [Kanban board](https://github.com/benedictkohtc/WDI-Project3-WhereWork/projects/1)
* [Google doc](https://docs.google.com/document/d/1PbUmWwnSvtdPrSZiPnzXaiuSnuTLBZ--ZdHJ2lwt2iU/edit?ts=589d76f8)
* [Entity-relation diagram](https://docs.google.com/spreadsheets/d/1KIO_9dBhnx9fjz8PFWqbmE0VqoEK7HaTetWNnj2VTyg/edit#gid=0)

## Post Mortem

* [Link](https://github.com/melvinthemok/WDI-Project3-WhereWork/blob/master/POSTMORTEM.md)

## Authors

* [Adrian](https://github.com/adrianke77)
* [Ben](https://github.com/benedictkohtc)
* [Keith](https://github.com/wekkit)
* [Melvin](https://github.com/melvinthemok)

## Acknowledgements

* [Kimverlyn Lim](https://sg.linkedin.com/in/kimverlynlim) for awesome UX advice!
