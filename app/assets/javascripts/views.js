function initMap () {
  let user_lat
  let user_lng
  let pos
  let types = [ 'wifi', 'aircon', 'sockets', 'coffee', 'quiet', 'uncrowded' ]
  let filterstates = {}
  let all_locations = []
  let shown_locations = []
  let markers = []
  let map = new google.maps.Map(document.getElementById('listMap'), {
    zoom: 16,
    center: { lat: 1.3072052, lng: 103.831843 },
    scaleControl: true,
    fullscreenControl: true
  })
  let userLocationInfoWindow = new google.maps.InfoWindow({ map: map })
  let infoWindow = new google.maps.InfoWindow()

  let defaultBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(1.077484, 103.582585),
    new google.maps.LatLng(1.490568, 104.093450)
  )
  let options = {
    bounds: defaultBounds
  }
  let input = document.getElementById('pac-input')
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(input)
  let autocomplete = new google.maps.places.Autocomplete(input, options)
  autocomplete.addListener('place_changed', function () {
    let place = autocomplete.getPlace()
    if (!place.geometry) {
      // User entered the name of a Place that was not suggested and pressed the Enter key, or the Place Details request failed.
      window.alert("No details available for input: '" + place.name + "'")
      return
    }
    map.setCenter(place.geometry.location)
    map.setZoom(16)
    userLocationInfoWindow.setPosition(place.geometry.location)
    userLocationInfoWindow.setContent('Your location')
    pos = {
      lat: place.geometry.location.lat(),
      lng: place.geometry.location.lng()
    }
    $.ajax({
      type: 'GET',
      url: '/locations/map_view',
      data: pos,
      contentType: 'application/json',
      dataType: 'json'
    }).done(function (response) {
      all_locations = response
      updateFiltering()
    })
  })

  function placeMarker (location) {
    let latLng = new google.maps.LatLng(location[ 'lat' ], location[ 'lng' ])
    let marker = new google.maps.Marker({
      position: latLng,
      map: map
    })
    google.maps.event.addListener(marker, 'click', function () {
      infoWindow.close()
      infoWindow.setContent("<div id= 'infoWindow'>" + "<a href='/locations/" + location[ 'id' ] + "'>" + location[ 'name' ] + '</a>' + '</div>')
      infoWindow.open(map, marker)
    })
    markers.push(marker)
  }

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (position) {
      user_lat = position.coords.latitude
      user_lng = position.coords.longitude
      $('#get_list_view').click(function () {
        window.location.href = '/locations/list_view/?lat=' + user_lat +
          '&lng=' + user_lng
      })
      pos = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      }
      userLocationInfoWindow.setPosition(pos)
      userLocationInfoWindow.setContent('Your location')
      map.setCenter(pos)
      $.ajax({
        type: 'GET',
        url: '/locations/map_view',
        data: pos,
        contentType: 'application/json',
        dataType: 'json'
      }).done(function (response) {
        all_locations = response
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
    types.forEach(type => {
      $('.button-' + type).click(function () {
        flipFilter(type)
      })
    })
  })

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
    types.forEach(type => {
      if (filterstates[ type ] === true) {
        $('.button-' + type)
          .removeClass('btn-default')
          .addClass('btn-primary')
        shown_locations.forEach((location, ind, arr) => {
          if (location[ type ] === false) {
            arr.splice(ind, 1)
          }
        })
      } else {
        $('.button-' + type)
        .addClass('btn-default')
        .removeClass('btn-primary')
      }
    })
    renderShownLocations()
  }

  function renderShownLocations () {
    // add markers to map
    shown_locations.forEach(location => placeMarker(location))
    //
  }
}

function handleLocationError (browserHasGeolocation, userLocationInfoWindow,
  pos) {
  userLocationInfoWindow.setPosition(pos)
  userLocationInfoWindow.setContent(browserHasGeolocation ?
    'Error: Please allow your Geolocation service.' :
    'Error: Your browser doesn\'t support geolocation.')
}
