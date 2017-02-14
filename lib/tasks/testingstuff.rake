task testingstuff: :environment do
  require 'rubygems'
  require 'httparty' # need to gem install
  require 'json'

  API_key = ENV['GOOGLE_PLACES_API_KEY']
  places_photo_url = 'https://maps.googleapis.com/maps/api/place/photo'
  photoreference = 'CoQBdwAAAF54FSG8f3S3JLex8IR3vJCqvUL3JGg8FVWfS84oym9_lzvkMe4wisGNxkNyEKUU5lmL25ZUClp03qeR7kTn6buGTmSg8TLjNQvmCEKwKJaqmC1L7oP_23F0I1GZ-nl7uL8zhZSxuSk7qAGqZqEFDvDJXKD7dcx0KDx6au-3VxyLEhBr_sNzY9vIuWsmSXi_ZDiaGhQQ2ynD-OsZf2pLlppe9paB-4E-JQ'
  maxheight = '800'
  maxwidth = '800'

  args_string = 'key=' + API_key + '&photoreference=' + photoreference + \
                '&maxheight=' + maxheight + '&maxwidth=' + maxwidth

  puts places_photo_url + '?' + args_string

  10.times do
    response = HTTParty.get(places_photo_url + '?' + args_string)

    puts 'RESPONSE.CODE:'
    puts response.code
    puts 'RESPONSE.MESSAGE:'
    puts response.message
    puts 'RESPONSE.HEADERS:'
    puts response.headers.inspect
  end

  File.open('./tempimages/testimage.jpg', 'wb') do |f|
    f.write response.body
  end
end
