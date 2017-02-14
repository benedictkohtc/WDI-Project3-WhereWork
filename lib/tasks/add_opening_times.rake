task add_opening_times: :environment do
  all_locations = Location.all
  all_locations.each do |l|
      l.openingtimes.create(day: 'monday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'tuesday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'wednesday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'thursday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'friday', opening_time: '9:00:00', closing_time: '17:30:00')
      l.openingtimes.create(day: 'saturday', opening_time: '9:00:00', closing_time: '19:00:00')
      l.openingtimes.create(day: 'sunday', opening_time: '9:00:00', closing_time: '19:00:00')
      l.openingtimes.create(day: 'publicholiday', opening_time: '9:00:00', closing_time: '17:30:00')
  end
end


