function initMap () {
  let search_position
  let search_position_lat
  let search_position_lng
  let types = [ 'wifi', 'aircon', 'availsockets', 'coffee', 'quiet', 'uncrowded' ]
  let filterstates = {}
  let all_locations = []
  let shown_locations = []
  let markers = []

  let map = new google.maps.Map(document.getElementById('listMap'), {
    zoom: 16,
    center: { lat: 1.3072052, lng: 103.831843 },
    scaleControl: true,
    fullscreenControl: true
  } )

  let userLocationInfoWindow = new google.maps.InfoWindow( { map: map } )
  let infoWindow = new google.maps.InfoWindow()

  // bias search results for start location in favour of locations in Singapore
  let autocompleteDefaultBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(1.077484, 103.582585),
    new google.maps.LatLng(1.490568, 104.093450)
  )
  let autocompleteOptions = {
    bounds: autocompleteDefaultBounds
  }

  // set up autocomplete search field and position it at the top edge, horizontally centered
  let input = document.getElementById('pac-input')
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(input)

  let autocomplete = new google.maps.places.Autocomplete(input, autocompleteOptions)
  autocomplete.addListener('place_changed', function () {
    let place = autocomplete.getPlace()
    if (!place.geometry) {
      // display an alert if the user enters the name of a Place that was not suggested and presses the Enter key, or if the Place Details request fails
      window.alert("No details available for input: '" + place.name + "'")
      return
    }
    map.setCenter(place.geometry.location)
    map.setZoom(16)
    userLocationInfoWindow.setPosition(place.geometry.location)
    userLocationInfoWindow.setContent('Your location')
    // send a get request to the controller with the search position as updated by the user, expecting a number of locations in response
    search_position = {
      lat: place.geometry.location.lat(),
      lng: place.geometry.location.lng()
    }
    $.ajax( {
      type: 'GET',
      url: '/locations/map_view',
      data: search_position,
      contentType: 'application/json',
      dataType: 'json'
    } ).done( function( response ) {
      all_locations = response
      all_locations.forEach( location => {
        location[ 'availsockets' ] =
          location[ 'available_sockets' ] > 0 ? true : false
        location[ 'uncrowded' ] =
          location[ 'available_seats' ] /
          location[ 'total_seats' ] > 0.3 ? true : false
      } )
      updateFiltering()

    } )
  } )

  // place a marker at each location provided by the controller
  function placeMarker (location) {
    let latLng = new google.maps.LatLng(location[ 'lat' ], location[ 'lng' ])
    let marker = new google.maps.Marker({
      position: latLng,
      map: map
    })
    // each time a marker is clicked, open an information window displaying the location name linked to its show view, and send the search position set by the user to the controller along with the request
    google.maps.event.addListener(marker, 'click', function () {
      infoWindow.close()
      search_position_lat = search_position['lat']
      search_position_lng = search_position['lng']
      infoWindow.setContent("<div id= 'infoWindow'>" + "<a href='/locations/" + location[ 'id' ] + '/?lat=' + search_position_lat + '&lng=' + search_position_lng + "'>" + location[ 'name' ] + '</a>' + '</div>')
      infoWindow.open(map, marker)
    })
    markers.push(marker)
  }

  // attempt to get the user's geolocation
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      // send a get request to the controller with the search position as found by geolocation, expecting a number of locations in response
      search_position = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
      userLocationInfoWindow.setPosition(search_position)
      userLocationInfoWindow.setContent('Your location')
      map.setCenter(search_position)
      $.ajax({
        type: 'GET',
        url: '/locations/map_view',
        data: search_position,
        contentType: 'application/json',
        dataType: 'json'
      }).done(function (response) {
        all_locations = response
        all_locations.forEach(location => {
          location[ 'availsockets' ] =
            location[ 'available_sockets' ] > 0 ? true : false
          location[ 'uncrowded' ] =
            location[ 'available_seats' ] /
            location[ 'total_seats' ] > 0.3 ? true : false
        })
        updateFiltering()
      })
    }, function () {
      handleLocationError(true, userLocationInfoWindow, map.getCenter())
    })
  } else {
    // Browser doesn't support Geolocation
    handleLocationError(false, userLocationInfoWindow, map.getCenter())
  };

  // FILTERING CODE

  // adds listeners to each button

  $(document).ready(function () {
    $('#switch-views').click(function () {
      flipView()
    })
    types.forEach(type => {
      $('.button-' + type).click(function () {
        flipFilter(type)
      })
    })
  })

  // changes view from map to list or vice versa
  function flipView () {
    if ($('#listCards').hasClass('hidden')) {
      $('#listCards').removeClass('hidden')
      $('#listMap').addClass('hidden')
      $('#switch-views').text('Map View')
    } else {
      $('#listCards').addClass('hidden')
      $('#listMap').removeClass('hidden')
      $('#switch-views').text('List View')
    }
  }

  // generates cards from shown_locations and updates $listCards
  function updateCards () {
    $('#listCards').empty()
    let cardslist = $('<div></div>')
    shown_locations.forEach(location => {
      let card = $('<div></div>')
      let imagelink = ''
      if (location['cloudinary_link']) { imagelink = `<img src=" ${location['cloudinary_link']} " alt='' class='img-responsive img-rounded center-block'>'` } else {
        imagelink = `<img src="http://placehold.it/300x300" alt="" class='img-responsive img-rounded center-block'>`
      }
      let walktime = Math.floor(location['distance'] / 40) + 1
      let filtersString = ''
      if ( location[ 'wifi' ] ) filtersString += 'wifi '
      if ( location[ 'aircon' ] ) filtersString += 'aircon '
      if ( location[ 'availsockets' ] ) filtersString += 'sockets '
      if ( location[ 'coffee' ] ) filtersString += 'coffee '
      if ( location[ 'quiet' ] ) filtersString += 'quiet '
      if ( location[ 'uncrowded' ] ) filtersString += 'uncrowded '
      let distance = Math.floor( location[ 'distance' ] )
      card.html(
        `
        <div class="well location-card row">
          <div class="col-xs-5 col-md-3 location-card-img">
            ${imagelink}
            <span class="label label-default">${walktime} min away</span>
          </div>
          <div class="col-xs-7 col-md-9">
          <h3> <a href="/locations/${location['id']}">${location['name']}</a> </h3>
          ${location['vicinity']}
          <br>
          ${filtersString}
          <hr>
          ${distance} metres away
          <hr>
          <p class="label label-default">${location['available_seats']} seats available</p>
          <p class="label label-default">${location['available_sockets']} sockets available</p>
          <hr>
          </div>
        </div>
        `
      )
      cardslist.append( card )
    } )
    $( '#listCards' ).append( cardslist )
  }

  // changes filterstates type
  function flipFilter (type) {
    filterstates[ type ] = filterstates[ type ] === true ? false : true
    updateFiltering()
  }

  // updates the shown_locations array according to the filters
  function updateFiltering () {
    markers.forEach(marker => marker.setMap(null))
    markers = []
    shown_locations = all_locations.slice()
    types.forEach( type => {
      if ( filterstates[ type ] === true ) {
        $( '.button-' + type )
          .removeClass( 'btn-default' )
          .addClass( 'btn-primary' )
        shown_locations = shown_locations.filter( ( location ) => {
          return location[ type ] == true
        } )
      } else {
        $('.button-' + type)
          .addClass('btn-default')
          .removeClass('btn-primary')
      }
    })
    renderShownLocations()
  }

  // updates both the map markers and the cards
  function renderShownLocations() {
    // add markers to map
    shown_locations.forEach( location => placeMarker( location ) )
      // update cards
    updateCards()
  }
}

function handleLocationError (browserHasGeolocation, userLocationInfoWindow,
  search_position) {
  userLocationInfoWindow.setPosition(search_position)
  userLocationInfoWindow.setContent(browserHasGeolocation ?
    'Error: Please allow your Geolocation service.' :
    'Error: Your browser doesn\'t support geolocation.')
}
