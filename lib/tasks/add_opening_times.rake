task add_opening_times: :environment do
  all_locations = Location.all
  all_locations.each do |l|
      l.openingtimes.create(day: 'Monday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'Tuesday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'Wednesday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'Thursday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'Friday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'Saturday', opening_time: '9:00:00', closing_time: '19:00:00')
      l.openingtimes.create(day: 'Sunday', opening_time: '9:00:00', closing_time: '19:00:00')
      l.openingtimes.create(day: 'Public Holidays', opening_time: '9:00:00', closing_time: '17:30:00')
  end
end


